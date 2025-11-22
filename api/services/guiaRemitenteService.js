/**
 * SERVICE - Capa de lógica de negocio
 * Orquesta llamadas al DAO, maneja transacciones complejas
 * Validaciones de negocio adicionales
 */

const guiaRemitenteDao = require('../dao/guiaRemitenteDao');

class GuiaRemitenteService {

    /**
     * Validar formato RUC (11 dígitos)
     */
    validateRuc(ruc) {
        return /^[0-9]{11}$/.test(ruc);
    }

    /**
     * Validar formato DNI (8 dígitos)
     */
    validateDni(dni) {
        return /^[0-9]{8}$/.test(dni);
    }

    /**
     * Guardar borrador de guía remitente
     */
    async saveDraft(data) {
        // Validaciones de negocio
        if (!this.validateRuc(data.ruc_transportista)) {
            throw new Error('RUC transportista inválido');
        }
        if (!this.validateRuc(data.ruc_destinatario)) {
            throw new Error('RUC destinatario inválido');
        }
        if (!this.validateRuc(data.ruc_remitente)) {
            throw new Error('RUC remitente inválido');
        }
        if (!this.validateDni(data.dni_conductor)) {
            throw new Error('DNI conductor inválido');
        }
        if (data.peso_total_traslado < 0) {
            throw new Error('Peso total no puede ser negativo');
        }

        // El SP hace validaciones adicionales (empresas activas, etc.)
        return await guiaRemitenteDao.saveDraft(data);
    }

    /**
     * Finalizar guía remitente
     */
    async finalize(numeroGuia, usuario) {
        if (!numeroGuia || !usuario) {
            throw new Error('Número de guía y usuario son obligatorios');
        }
        return await guiaRemitenteDao.finalize(numeroGuia, usuario);
    }

    /**
     * Agregar detalle a guía remitente
     */
    async addDetalle(data) {
        // Validaciones
        if (data.numero_item <= 0) {
            throw new Error('Número de ítem debe ser mayor a 0');
        }
        if (data.peso_bruto < 0 || data.peso_neto < 0 || data.peso_tara < 0) {
            throw new Error('Los pesos no pueden ser negativos');
        }

        return await guiaRemitenteDao.insertDetalle(data);
    }

    /**
     * Actualizar detalle
     */
    async updateDetalle(data) {
        if (data.peso_bruto < 0 || data.peso_neto < 0 || data.peso_tara < 0) {
            throw new Error('Los pesos no pueden ser negativos');
        }
        return await guiaRemitenteDao.updateDetalle(data);
    }

    /**
     * Eliminar detalle (lógico)
     */
    async deleteDetalle(numeroGuia, numeroItem, usuario) {
        return await guiaRemitenteDao.deleteDetalle(numeroGuia, numeroItem, usuario);
    }

    /**
     * Listar guías remitente
     */
    async list(filters) {
        return await guiaRemitenteDao.list(filters);
    }

    /**
     * Obtener guía con sus detalles
     */
    async getWithDetails(numeroGuia) {
        const guia = await guiaRemitenteDao.getByNumero(numeroGuia);
        if (!guia) {
            throw new Error('Guía remitente no encontrada');
        }
        
        const detalles = await guiaRemitenteDao.getDetalles(numeroGuia);
        
        return {
            guia,
            detalles
        };
    }

 async createGTFromRemitentes(data) {
    // Validaciones básicas del payload
    if (!Array.isArray(data.remitentes) || data.remitentes.length === 0) {
      throw new Error('Debe proporcionar al menos una guía remitente');
    }
    if (!data.numero_guia_transportista || String(data.numero_guia_transportista).trim() === '') {
      throw new Error('Número de guía transportista es obligatorio');
    }

    // Normalizar unidad de medida
    const allowedUnits = ['KGM', 'TNE'];
    if (!data.unidad_medida) data.unidad_medida = 'KGM';
    if (!allowedUnits.includes(data.unidad_medida)) {
      throw new Error(`Unidad de medida inválida. Valores permitidos: ${allowedUnits.join(', ')}`);
    }

    // Validar fecha inicio traslado
    if (!data.fecha_inicio_traslado) {
      throw new Error('Fecha inicio de traslado es obligatoria');
    }

    // Asegurar indicadores en 0/1
    const boolTo0or1 = v => (v ? 1 : 0);
    data.indicador_pagador_flete = boolTo0or1(data.indicador_pagador_flete);
    data.indicador_transporte_subcontratado = boolTo0or1(data.indicador_transporte_subcontratado);
    data.indicador_transbordo_programado = boolTo0or1(data.indicador_transbordo_programado);
    data.indicador_retorno_vehiculo_vacio = boolTo0or1(data.indicador_retorno_vehiculo_vacio);
    data.indicador_retorno_envases_vacios = boolTo0or1(data.indicador_retorno_envases_vacios);

    // Validar cada remitente: existe, está activo y NO tiene GT asignada
    const missing = [];
    const alreadyAssigned = [];
    for (const numero of data.remitentes) {
      const gr = await guiaRemitenteDao.getByNumero(numero);
      if (!gr) {
        missing.push(numero);
        continue;
      }
      // gr.activo puede ser 0/1 o boolean; adaptamos
      if (gr.activo === 0 || gr.activo === '0' || gr.activo === false) {
        missing.push(numero); // lo tratamos como no válido
        continue;
      }
      if (gr.numero_guia_transportista) {
        alreadyAssigned.push(numero);
      }
    }

    if (missing.length) {
      throw new Error(`Las siguientes guías remitente no existen o están inactivas: ${missing.join(', ')}`);
    }
    if (alreadyAssigned.length) {
      throw new Error(`Las siguientes guías ya tienen guía transportista asignada: ${alreadyAssigned.join(', ')}`);
    }

    // Todo validado localmente; llamar al DAO (SP)
    // Nota: DAO hará protección final (undefined -> null)
    return await guiaRemitenteDao.createGTFromRemitentes(data);
  }


    /**
     * Ejecutar reporte
     * Valida nombre de reporte contra whitelist
     */
    async executeReport(reportId, params) {
        const validReports = {
            '1': { name: 'sp_report_gt_por_rango_fecha', params: ['fecha_ini', 'fecha_fin'] },
            '2': { name: 'sp_report_gt_por_numero', params: ['numero_guia'] },
            '3': { name: 'sp_report_gr_por_rango_y_transportista', params: ['fecha_ini', 'fecha_fin', 'ruc_transportista'] },
            '4': { name: 'sp_report_gt_por_horario', params: ['fecha_ini', 'fecha_fin', 'hora_ini', 'hora_fin'] },
            '5': { name: 'sp_report_transporte_subcontratado', params: ['fecha_ini', 'fecha_fin'] },
            '6': { name: 'sp_report_detalle_gr', params: ['numero_guia_remitente'] },
            '7': { name: 'sp_report_conductor_frecuencia', params: ['fecha_ini', 'fecha_fin'] },
            '8': { name: 'sp_report_trazabilidad', params: ['fecha_ini', 'fecha_fin'] },
            '9': { name: 'sp_report_productos_mas_transportados', params: ['fecha_ini', 'fecha_fin'] },
            '10': { name: 'sp_report_resumen_por_empresa', params: ['fecha_ini', 'fecha_fin'] }
        };

        const report = validReports[reportId];
        if (!report) {
            throw new Error('Reporte no válido');
        }

        // Validar que se proporcionen los parámetros correctos
        const paramValues = report.params.map(p => params[p]);
        if (paramValues.some(v => v === undefined)) {
            throw new Error(`Parámetros faltantes para reporte ${reportId}: ${report.params.join(', ')}`);
        }

        return await guiaRemitenteDao.executeReport(report.name, paramValues);
    }
}

module.exports = new GuiaRemitenteService();
