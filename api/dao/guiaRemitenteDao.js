/**
 * DAO - Data Access Object para Guía Remitente
 * Capa única que ejecuta CALL sp_... y prepared statements
 * Todas las mutaciones se hacen por procedimientos almacenados
 */

const pool = require('../db');

class GuiaRemitenteDao {
    
    /**
     * Guardar borrador de guía remitente
     * Llama a sp_gr_save_draft
     */
    async saveDraft(data) {
        const conn = await pool.getConnection();
        try {
            const [rows] = await conn.execute(
                `CALL sp_gr_save_draft(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                [
                    data.numero_guia_remitente,
                    data.ruc_transportista,
                    data.ruc_destinatario,
                    data.ruc_remitente,
                    data.cod_local_llegada,
                    data.cod_local_partida,
                    data.fecha_entrega_bienes,
                    data.modalidad_traslado,
                    data.hora_emision,
                    data.fecha_emision,
                    data.motivo_traslado,
                    data.observaciones,
                    data.peso_total_traslado,
                    data.dni_conductor,
                    data.placa_tracto,
                    data.usuario
                ]
            );
            return rows[0][0]; // Primer resultset, primera fila
        } finally {
            conn.release();
        }
    }

    /**
     * Finalizar guía remitente
     * Llama a sp_gr_finalize
     */
    async finalize(numeroGuia, usuario) {
        const conn = await pool.getConnection();
        try {
            const [rows] = await conn.execute(
                `CALL sp_gr_finalize(?, ?)`,
                [numeroGuia, usuario]
            );
            return rows[0][0];
        } finally {
            conn.release();
        }
    }

    /**
     * Insertar detalle de guía remitente
     * Llama a sp_detalle_insert
     */
    async insertDetalle(data) {
        const conn = await pool.getConnection();
        try {
            const [rows] = await conn.execute(
                `CALL sp_detalle_insert(?, ?, ?, ?, ?, ?, ?)`,
                [
                    data.numero_guia_remitente,
                    data.numero_item,
                    data.codigo_producto,
                    data.peso_tara,
                    data.peso_neto,
                    data.peso_bruto,
                    data.usuario
                ]
            );
            return rows[0][0];
        } finally {
            conn.release();
        }
    }

    /**
     * Actualizar detalle
     * Llama a sp_detalle_update
     */
    async updateDetalle(data) {
        const conn = await pool.getConnection();
        try {
            const [rows] = await conn.execute(
                `CALL sp_detalle_update(?, ?, ?, ?, ?, ?, ?)`,
                [
                    data.numero_guia_remitente,
                    data.numero_item,
                    data.codigo_producto,
                    data.peso_tara,
                    data.peso_neto,
                    data.peso_bruto,
                    data.usuario
                ]
            );
            return rows[0][0];
        } finally {
            conn.release();
        }
    }

    /**
     * Borrado lógico de detalle
     * Llama a sp_detalle_soft_delete
     */
    async deleteDetalle(numeroGuia, numeroItem, usuario) {
        const conn = await pool.getConnection();
        try {
            const [rows] = await conn.execute(
                `CALL sp_detalle_soft_delete(?, ?, ?)`,
                [numeroGuia, numeroItem, usuario]
            );
            return rows[0][0];
        } finally {
            conn.release();
        }
    }

    /**
     * Listar guías remitente (lectura directa, sin SP)
     * Filtros opcionales
     */
    async list(filters = {}) {
        const conn = await pool.getConnection();
        try {
            let query = `
                SELECT gr.*, 
                       e_rem.razon_social AS remitente_razon,
                       e_dest.razon_social AS destinatario_razon
                FROM guia_remitente gr
                INNER JOIN empresa e_rem ON gr.ruc_remitente = e_rem.ruc
                INNER JOIN empresa e_dest ON gr.ruc_destinatario = e_dest.ruc
                WHERE gr.activo = 1
            `;
            const params = [];

            if (filters.fecha_desde) {
                query += ` AND gr.fecha_emision >= ?`;
                params.push(filters.fecha_desde);
            }
            if (filters.fecha_hasta) {
                query += ` AND gr.fecha_emision <= ?`;
                params.push(filters.fecha_hasta);
            }
            if (filters.ruc_transportista) {
                query += ` AND gr.ruc_transportista = ?`;
                params.push(filters.ruc_transportista);
            }

            query += ` ORDER BY gr.fecha_emision DESC LIMIT 100`;

            const [rows] = await conn.execute(query, params);
            return rows;
        } finally {
            conn.release();
        }
    }

    /**
     * Obtener una guía por número
     */
    async getByNumero(numeroGuia) {
        const conn = await pool.getConnection();
        try {
            const [rows] = await conn.execute(
                `SELECT gr.*,
                        e_rem.razon_social AS remitente_razon,
                        e_dest.razon_social AS destinatario_razon,
                        c.nombre_conductor
                 FROM guia_remitente gr
                 INNER JOIN empresa e_rem ON gr.ruc_remitente = e_rem.ruc
                 INNER JOIN empresa e_dest ON gr.ruc_destinatario = e_dest.ruc
                 INNER JOIN conductor c ON gr.dni_conductor = c.dni_conductor
                 WHERE gr.numero_guia_remitente = ? AND gr.activo = 1`,
                [numeroGuia]
            );
            return rows[0] || null;
        } finally {
            conn.release();
        }
    }

    /**
     * Obtener detalles de una guía remitente
     */
    async getDetalles(numeroGuia) {
        const conn = await pool.getConnection();
        try {
            const [rows] = await conn.execute(
                `SELECT dgr.*, p.descripcion AS producto_descripcion, p.unidad_medida
                 FROM detalle_guia_remitente dgr
                 INNER JOIN producto p ON dgr.codigo_producto = p.codigo_producto
                 WHERE dgr.numero_guia_remitente = ? AND dgr.activo = 1
                 ORDER BY dgr.numero_item`,
                [numeroGuia]
            );
            return rows;
        } finally {
            conn.release();
        }
    }

    /**
     * Crear guía transportista desde remitentes
     * Llama a sp_gt_create_from_remitentes
     */
// api/dao/guiaRemitenteDao.js
async createGTFromRemitentes(data) {
    const conn = await pool.getConnection();
    try {
        // Asegurar formato de remitentes: array de strings
        const remitentesJson = JSON.stringify(data.remitentes);

        const params = [
            data.numero_guia_transportista,
            remitentesJson,
            data.ruc_transportista || null,
            (data.ruc_subcontratado === undefined ? null : data.ruc_subcontratado),
            (data.ruc_pagador_flete === undefined ? null : data.ruc_pagador_flete),
            (data.fecha_inicio_traslado === undefined ? null : data.fecha_inicio_traslado),
            (data.unidad_medida === undefined ? null : data.unidad_medida),
            (data.indicador_pagador_flete === undefined ? 0 : Number(data.indicador_pagador_flete)),
            (data.indicador_transporte_subcontratado === undefined ? 0 : Number(data.indicador_transporte_subcontratado)),
            (data.indicador_transbordo_programado === undefined ? 0 : Number(data.indicador_transbordo_programado)),
            (data.indicador_retorno_vehiculo_vacio === undefined ? 0 : Number(data.indicador_retorno_vehiculo_vacio)),
            (data.indicador_retorno_envases_vacios === undefined ? 0 : Number(data.indicador_retorno_envases_vacios)),
            (data.observaciones === undefined ? null : data.observaciones),
            (data.numero_registro_mtc === undefined ? null : data.numero_registro_mtc),
            data.usuario
        ];

        // Protección final: undefined -> null
        const safeParams = params.map(p => p === undefined ? null : p);

        // LOG: parámetros (útil para depuración en caso de rollback)
        console.log('Llamando sp_gt_create_from_remitentes con params:', {
            numero_guia_transportista: data.numero_guia_transportista,
            remitentesCount: data.remitentes.length,
            remitentesPreview: data.remitentes.slice(0,10),
            ruc_transportista: data.ruc_transportista,
            fecha_inicio_traslado: data.fecha_inicio_traslado,
            unidad_medida: data.unidad_medida,
            indicadores: {
                pagador_flete: safeParams[7],
                transporte_subcontratado: safeParams[8],
                transbordo_programado: safeParams[9]
            },
            usuario: data.usuario
        });

        try {
            const [rows] = await conn.execute(
                `CALL sp_gt_create_from_remitentes(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                safeParams
            );
            return rows[0] && rows[0][0] ? rows[0][0] : { mensaje: 'OK' };
        } catch (err) {
            // Si el SP hace SIGNAL con ER_SIGNAL_EXCEPTION, mostramos mensaje claro
            console.error('Error ejecutando SP sp_gt_create_from_remitentes:', err && err.sqlMessage ? err.sqlMessage : err);
            // Re-lanzar con mensaje más amigable que incluya detalle del SP
            const msg = (err && err.sqlMessage) ? `SP error: ${err.sqlMessage}` : (err && err.message) ? err.message : 'Error al ejecutar SP';
            const e = new Error(msg);
            // preservar código/errno si existe
            if (err && err.code) e.code = err.code;
            throw e;
        }
    } finally {
        conn.release();
    }
}


    /**
     * Ejecutar reporte genérico
     * Permite llamar a cualquier sp_report_*
     */
    async executeReport(reportName, params) {
        const conn = await pool.getConnection();
        try {
            // Construir CALL dinámico (validar reportName en service)
            const placeholders = params.map(() => '?').join(', ');
            const query = `CALL ${reportName}(${placeholders})`;
            
            const [rows] = await conn.execute(query, params);
            return rows[0]; // Primer resultset
        } finally {
            conn.release();
        }
    }
}

module.exports = new GuiaRemitenteDao();
