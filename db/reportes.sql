-- ============================================================================
-- PROCEDIMIENTOS DE REPORTES - SISTEMA GUÍA TRANSPORTISTA
-- Versión: 1.0
-- Propósito: Implementar las 10 consultas requeridas como procedimientos
-- Todos los reportes usan JOINs y están optimizados con índices
-- ============================================================================

USE transportista;

DELIMITER $$

-- ============================================================================
-- REPORTE 1: Búsqueda masiva de GT por rango de fechas
-- Índice utilizado: idx_gt_fecha_emision
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_report_gt_por_rango_fecha$$
CREATE PROCEDURE sp_report_gt_por_rango_fecha(
    IN p_fecha_ini DATE,
    IN p_fecha_fin DATE
)
BEGIN
    -- Validar fechas
    IF p_fecha_ini > p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha inicial no puede ser mayor que fecha final';
    END IF;
    
    SELECT 
        gt.numero_guia_transportista,
        gt.fecha_emision,
        gt.hora_emision,
        gt.fecha_inicio_traslado,
        e_rem.razon_social AS remitente,
        e_dest.razon_social AS destinatario,
        gt.peso_bruto_total,
        gt.unidad_medida_peso_bruto,
        gt.numero_registro_mtc
    FROM guia_transportista gt
    INNER JOIN empresa e_rem ON gt.ruc_remitente = e_rem.ruc
    INNER JOIN empresa e_dest ON gt.ruc_destinatario = e_dest.ruc
    WHERE gt.fecha_emision BETWEEN p_fecha_ini AND p_fecha_fin
      AND gt.activo = 1
    ORDER BY gt.fecha_emision DESC, gt.hora_emision DESC;
END$$

-- ============================================================================
-- REPORTE 2: Búsqueda individual de GT por número
-- Índice utilizado: PRIMARY KEY (numero_guia_transportista)
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_report_gt_por_numero$$
CREATE PROCEDURE sp_report_gt_por_numero(
    IN p_numero_guia VARCHAR(20)
)
BEGIN
    IF TRIM(p_numero_guia) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Número de guía es obligatorio';
    END IF;
    
    SELECT 
        gt.numero_guia_transportista,
        gt.fecha_emision,
        gt.hora_emision,
        gt.fecha_inicio_traslado,
        e_trans.razon_social AS transportista,
        e_rem.razon_social AS remitente,
        e_dest.razon_social AS destinatario,
        gt.peso_bruto_total,
        gt.unidad_medida_peso_bruto,
        gt.indicador_transporte_subcontratado,
        CASE WHEN gt.indicador_transporte_subcontratado = 1 
             THEN e_sub.razon_social 
             ELSE 'N/A' 
        END AS subcontratista,
        gt.observaciones
    FROM guia_transportista gt
    INNER JOIN empresa e_trans ON gt.ruc_transportista = e_trans.ruc
    INNER JOIN empresa e_rem ON gt.ruc_remitente = e_rem.ruc
    INNER JOIN empresa e_dest ON gt.ruc_destinatario = e_dest.ruc
    LEFT JOIN empresa e_sub ON gt.ruc_subcontratado = e_sub.ruc
    WHERE gt.numero_guia_transportista = p_numero_guia
      AND gt.activo = 1;
END$$

-- ============================================================================
-- REPORTE 3: GR por rango de fechas y transportista
-- Índices utilizados: idx_gr_fecha_emision, idx_gr_RUC_transportista
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_report_gr_por_rango_y_transportista$$
CREATE PROCEDURE sp_report_gr_por_rango_y_transportista(
    IN p_fecha_ini DATE,
    IN p_fecha_fin DATE,
    IN p_ruc_transportista CHAR(11)
)
BEGIN
    IF p_fecha_ini > p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha inicial no puede ser mayor que fecha final';
    END IF;
    
    IF p_ruc_transportista NOT REGEXP '^[0-9]{11}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RUC inválido';
    END IF;
    
    SELECT 
        gr.numero_guia_remitente,
        gr.fecha_emision,
        gr.hora_emision,
        gr.fecha_entrega_bienes,
        gr.modalidad_traslado,
        gr.motivo_traslado,
        e_trans.razon_social AS transportista,
        e_rem.razon_social AS remitente,
        e_dest.razon_social AS destinatario,
        gr.peso_total_traslado,
        c.nombre_conductor,
        gr.placa_tracto
    FROM guia_remitente gr
    INNER JOIN empresa e_trans ON gr.ruc_transportista = e_trans.ruc
    INNER JOIN empresa e_rem ON gr.ruc_remitente = e_rem.ruc
    INNER JOIN empresa e_dest ON gr.ruc_destinatario = e_dest.ruc
    INNER JOIN conductor c ON gr.dni_conductor = c.dni_conductor
    WHERE gr.fecha_emision BETWEEN p_fecha_ini AND p_fecha_fin
      AND gr.ruc_transportista = p_ruc_transportista
      AND gr.activo = 1
    ORDER BY gr.fecha_emision DESC;
END$$

-- ============================================================================
-- REPORTE 4: Búsqueda por rango de horas
-- Índice utilizado: idx_gt_fecha_emision
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_report_gt_por_horario$$
CREATE PROCEDURE sp_report_gt_por_horario(
    IN p_fecha_ini DATE,
    IN p_fecha_fin DATE,
    IN p_hora_ini TIME,
    IN p_hora_fin TIME
)
BEGIN
    IF p_fecha_ini > p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha inicial no puede ser mayor que fecha final';
    END IF;
    
    IF p_hora_ini > p_hora_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hora inicial no puede ser mayor que hora final';
    END IF;
    
    SELECT 
        gt.numero_guia_transportista,
        gt.fecha_emision,
        gt.hora_emision,
        e_trans.razon_social AS transportista,
        e_rem.razon_social AS remitente,
        gt.peso_bruto_total,
        gt.unidad_medida_peso_bruto
    FROM guia_transportista gt
    INNER JOIN empresa e_trans ON gt.ruc_transportista = e_trans.ruc
    INNER JOIN empresa e_rem ON gt.ruc_remitente = e_rem.ruc
    WHERE gt.fecha_emision BETWEEN p_fecha_ini AND p_fecha_fin
      AND gt.hora_emision BETWEEN p_hora_ini AND p_hora_fin
      AND gt.activo = 1
    ORDER BY gt.fecha_emision DESC, gt.hora_emision ASC;
END$$

-- ============================================================================
-- REPORTE 5: Transporte subcontratado
-- Índice utilizado: idx_gt_RUC_subcontratado
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_report_transporte_subcontratado$$
CREATE PROCEDURE sp_report_transporte_subcontratado(
    IN p_fecha_ini DATE,
    IN p_fecha_fin DATE
)
BEGIN
    IF p_fecha_ini > p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha inicial no puede ser mayor que fecha final';
    END IF;
    
    SELECT 
        gt.numero_guia_transportista,
        gt.fecha_emision,
        e_trans.razon_social AS transportista_principal,
        e_sub.razon_social AS subcontratista,
        e_pag.razon_social AS pagador_flete,
        gt.peso_bruto_total,
        gt.unidad_medida_peso_bruto,
        gt.numero_registro_mtc
    FROM guia_transportista gt
    INNER JOIN empresa e_trans ON gt.ruc_transportista = e_trans.ruc
    INNER JOIN empresa e_sub ON gt.ruc_subcontratado = e_sub.ruc
    INNER JOIN empresa e_pag ON gt.ruc_pagador_flete = e_pag.ruc
    WHERE gt.indicador_transporte_subcontratado = 1
      AND gt.fecha_emision BETWEEN p_fecha_ini AND p_fecha_fin
      AND gt.activo = 1
    ORDER BY gt.fecha_emision DESC;
END$$

-- ============================================================================
-- REPORTE 6: Detalle completo de una GR con productos
-- Índices utilizados: idx_det_numero_guia, idx_det_codigo_producto
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_report_detalle_gr$$
CREATE PROCEDURE sp_report_detalle_gr(
    IN p_numero_guia_remitente VARCHAR(20)
)
BEGIN
    IF TRIM(p_numero_guia_remitente) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Número de guía remitente es obligatorio';
    END IF;
    
    SELECT 
        gr.numero_guia_remitente,
        gr.fecha_emision,
        e_rem.razon_social AS remitente,
        e_dest.razon_social AS destinatario,
        dgr.numero_item,
        p.descripcion AS producto,
        p.material,
        p.unidad_medida,
        dgr.peso_tara,
        dgr.peso_neto,
        dgr.peso_bruto,
        p.lote
    FROM guia_remitente gr
    INNER JOIN empresa e_rem ON gr.ruc_remitente = e_rem.ruc
    INNER JOIN empresa e_dest ON gr.ruc_destinatario = e_dest.ruc
    INNER JOIN detalle_guia_remitente dgr ON gr.numero_guia_remitente = dgr.numero_guia_remitente
    INNER JOIN producto p ON dgr.codigo_producto = p.codigo_producto
    WHERE gr.numero_guia_remitente = p_numero_guia_remitente
      AND gr.activo = 1
      AND dgr.activo = 1
    ORDER BY dgr.numero_item;
END$$

-- ============================================================================
-- REPORTE 7: Análisis de conductores y frecuencia de viajes
-- Índices utilizados: idx_gr_dni_conductor, idx_conductor_nombre
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_report_conductor_frecuencia$$
CREATE PROCEDURE sp_report_conductor_frecuencia(
    IN p_fecha_ini DATE,
    IN p_fecha_fin DATE
)
BEGIN
    IF p_fecha_ini > p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha inicial no puede ser mayor que fecha final';
    END IF;
    
    SELECT 
        c.dni_conductor,
        c.nombre_conductor,
        c.numero_licencia_conductor,
        COUNT(DISTINCT gr.numero_guia_remitente) AS total_viajes,
        SUM(gr.peso_total_traslado) AS peso_total_transportado,
        MIN(gr.fecha_emision) AS primer_viaje,
        MAX(gr.fecha_emision) AS ultimo_viaje,
        COUNT(DISTINCT gr.placa_tracto) AS vehiculos_utilizados
    FROM conductor c
    INNER JOIN guia_remitente gr ON c.dni_conductor = gr.dni_conductor
    WHERE gr.fecha_emision BETWEEN p_fecha_ini AND p_fecha_fin
      AND gr.activo = 1
      AND c.activo = 1
    GROUP BY c.dni_conductor, c.nombre_conductor, c.numero_licencia_conductor
    ORDER BY total_viajes DESC;
END$$

-- ============================================================================
-- REPORTE 8: Trazabilidad completa de transporte
-- Índices utilizados: idx_gr_numero_gt, idx_info_numero_guia
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_report_trazabilidad$$
CREATE PROCEDURE sp_report_trazabilidad(
    IN p_fecha_ini DATE,
    IN p_fecha_fin DATE
)
BEGIN
    IF p_fecha_ini > p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha inicial no puede ser mayor que fecha final';
    END IF;
    
    SELECT 
        gr.numero_guia_remitente,
        gr.fecha_emision AS fecha_emision_gr,
        gt.numero_guia_transportista,
        gt.fecha_emision AS fecha_emision_gt,
        e_rem.razon_social AS remitente,
        e_dest.razon_social AS destinatario,
        c.nombre_conductor,
        c.numero_licencia_conductor,
        t.placa_tracto,
        t.marca_unidad AS marca_tracto,
        s.placa_semirremolque,
        gr.peso_total_traslado,
        gt.peso_bruto_total,
        gr.modalidad_traslado,
        gt.indicador_transporte_subcontratado
    FROM guia_remitente gr
    INNER JOIN guia_transportista gt ON gr.numero_guia_transportista = gt.numero_guia_transportista
    INNER JOIN empresa e_rem ON gr.ruc_remitente = e_rem.ruc
    INNER JOIN empresa e_dest ON gr.ruc_destinatario = e_dest.ruc
    INNER JOIN conductor c ON gr.dni_conductor = c.dni_conductor
    INNER JOIN tracto t ON gr.placa_tracto = t.placa_tracto
    LEFT JOIN semirremolque s ON gr.numero_guia_remitente = s.numero_guia_remitente
    WHERE gr.numero_guia_transportista IS NOT NULL
      AND gr.fecha_emision BETWEEN p_fecha_ini AND p_fecha_fin
      AND gr.activo = 1
      AND gt.activo = 1
    ORDER BY gr.fecha_emision DESC;
END$$

-- ============================================================================
-- REPORTE 9: Productos más transportados
-- Índices utilizados: idx_det_codigo_producto, ft_producto_descripcion
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_report_productos_mas_transportados$$
CREATE PROCEDURE sp_report_productos_mas_transportados(
    IN p_fecha_ini DATE,
    IN p_fecha_fin DATE
)
BEGIN
    IF p_fecha_ini > p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha inicial no puede ser mayor que fecha final';
    END IF;
    
    SELECT 
        p.codigo_producto,
        p.descripcion,
        p.material,
        p.unidad_medida,
        COUNT(DISTINCT dgr.numero_guia_remitente) AS total_guias,
        SUM(dgr.peso_neto) AS peso_neto_total,
        SUM(dgr.peso_bruto) AS peso_bruto_total,
        AVG(dgr.peso_bruto) AS peso_bruto_promedio,
        MIN(gr.fecha_emision) AS primera_fecha,
        MAX(gr.fecha_emision) AS ultima_fecha
    FROM producto p
    INNER JOIN detalle_guia_remitente dgr ON p.codigo_producto = dgr.codigo_producto
    INNER JOIN guia_remitente gr ON dgr.numero_guia_remitente = gr.numero_guia_remitente
    WHERE gr.fecha_emision BETWEEN p_fecha_ini AND p_fecha_fin
      AND gr.activo = 1
      AND dgr.activo = 1
      AND p.activo = 1
    GROUP BY p.codigo_producto, p.descripcion, p.material, p.unidad_medida
    ORDER BY peso_bruto_total DESC;
END$$

-- ============================================================================
-- REPORTE 10: Resumen de operaciones por empresa
-- Índices utilizados: idx_gt_RUC_transportista, idx_gt_fecha_emision
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_report_resumen_por_empresa$$
CREATE PROCEDURE sp_report_resumen_por_empresa(
    IN p_fecha_ini DATE,
    IN p_fecha_fin DATE
)
BEGIN
    IF p_fecha_ini > p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha inicial no puede ser mayor que fecha final';
    END IF;
    
    SELECT 
        e.ruc,
        e.razon_social,
        e.departamento,
        e.distrito,
        COUNT(DISTINCT gt.numero_guia_transportista) AS total_guias_transportista,
        COUNT(DISTINCT gr.numero_guia_remitente) AS total_guias_remitente_asociadas,
        SUM(gt.peso_bruto_total) AS peso_total_transportado,
        COUNT(DISTINCT CASE WHEN gt.indicador_transporte_subcontratado = 1 
                            THEN gt.numero_guia_transportista END) AS servicios_subcontratados,
        COUNT(DISTINCT it.dni_conductor) AS conductores_utilizados,
        COUNT(DISTINCT it.placa_tracto) AS vehiculos_utilizados,
        MIN(gt.fecha_emision) AS primera_operacion,
        MAX(gt.fecha_emision) AS ultima_operacion,
        DATEDIFF(MAX(gt.fecha_emision), MIN(gt.fecha_emision)) AS dias_operacion
    FROM empresa e
    INNER JOIN guia_transportista gt ON e.ruc = gt.ruc_transportista
    LEFT JOIN guia_remitente gr ON gt.numero_guia_transportista = gr.numero_guia_transportista
    LEFT JOIN info_transporte it ON gt.numero_guia_transportista = it.numero_guia_transportista
    WHERE gt.fecha_emision BETWEEN p_fecha_ini AND p_fecha_fin
      AND gt.activo = 1
      AND e.activo = 1
    GROUP BY e.ruc, e.razon_social, e.departamento, e.distrito
    ORDER BY total_guias_transportista DESC;
END$$

DELIMITER ;

-- ============================================================================
-- TESTS DE EJEMPLO PARA LOS REPORTES
-- Ejecutar con fechas: 2025-09-01 a 2025-10-24
-- ============================================================================

-- Test Reporte 1
CALL sp_report_gt_por_rango_fecha('2025-09-01', '2025-10-24');

-- Test Reporte 2
CALL sp_report_gt_por_numero('EG03-00001374');

-- Test Reporte 3
CALL sp_report_gr_por_rango_y_transportista('2025-09-01', '2025-10-24', '20497947384');

-- Test Reporte 4 (horario matutino)
CALL sp_report_gt_por_horario('2025-10-01', '2025-10-24', '08:00:00', '11:59:59');

-- Test Reporte 5
CALL sp_report_transporte_subcontratado('2025-10-01', '2025-10-24');

-- Test Reporte 6
CALL sp_report_detalle_gr('T001-00000199');

-- Test Reporte 7
CALL sp_report_conductor_frecuencia('2025-09-01', '2025-10-24');

-- Test Reporte 8
CALL sp_report_trazabilidad('2025-10-01', '2025-10-24');

-- Test Reporte 9
CALL sp_report_productos_mas_transportados('2025-09-01', '2025-10-24');

-- Test Reporte 10
CALL sp_report_resumen_por_empresa('2025-09-01', '2025-10-24');

-- ============================================================================
-- FIN DE REPORTES
-- ============================================================================
