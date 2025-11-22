-- ============================================================================
-- TRIGGERS DE AUDITORÍA - SISTEMA GUÍA TRANSPORTISTA
-- Versión: 1.0
-- Propósito: Registrar cambios en audit_log para trazabilidad
-- Nota: Los triggers tienen limitaciones con variables de sesión.
--       Para operaciones con p_usuario, los SPs insertan directamente en audit_log.
--       Estos triggers capturan cambios directos en las tablas (casos excepcionales).
-- ============================================================================

USE transportista;

DELIMITER $$

-- ============================================================================
-- TRIGGERS: EMPRESA
-- ============================================================================

DROP TRIGGER IF EXISTS trg_empresa_after_insert$$
CREATE TRIGGER trg_empresa_after_insert
AFTER INSERT ON empresa
FOR EACH ROW
BEGIN
    -- Solo registrar si no fue por SP (los SPs ya auditan)
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
        VALUES ('empresa', 'INSERT', NEW.ruc, 'SYSTEM',
                JSON_OBJECT('ruc', NEW.ruc, 'razon_social', NEW.razon_social, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_empresa_after_update$$
CREATE TRIGGER trg_empresa_after_update
AFTER UPDATE ON empresa
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
        VALUES ('empresa', 'UPDATE', NEW.ruc, 'SYSTEM',
                JSON_OBJECT('ruc', OLD.ruc, 'razon_social', OLD.razon_social, 'activo', OLD.activo),
                JSON_OBJECT('ruc', NEW.ruc, 'razon_social', NEW.razon_social, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_empresa_after_delete$$
CREATE TRIGGER trg_empresa_after_delete
AFTER DELETE ON empresa
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old)
    VALUES ('empresa', 'DELETE', OLD.ruc, 'SYSTEM',
            JSON_OBJECT('ruc', OLD.ruc, 'razon_social', OLD.razon_social));
END$$

-- ============================================================================
-- TRIGGERS: CONDUCTOR
-- ============================================================================

DROP TRIGGER IF EXISTS trg_conductor_after_insert$$
CREATE TRIGGER trg_conductor_after_insert
AFTER INSERT ON conductor
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
        VALUES ('conductor', 'INSERT', NEW.dni_conductor, 'SYSTEM',
                JSON_OBJECT('dni', NEW.dni_conductor, 'nombre', NEW.nombre_conductor, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_conductor_after_update$$
CREATE TRIGGER trg_conductor_after_update
AFTER UPDATE ON conductor
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
        VALUES ('conductor', 'UPDATE', NEW.dni_conductor, 'SYSTEM',
                JSON_OBJECT('dni', OLD.dni_conductor, 'nombre', OLD.nombre_conductor, 'activo', OLD.activo),
                JSON_OBJECT('dni', NEW.dni_conductor, 'nombre', NEW.nombre_conductor, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_conductor_after_delete$$
CREATE TRIGGER trg_conductor_after_delete
AFTER DELETE ON conductor
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old)
    VALUES ('conductor', 'DELETE', OLD.dni_conductor, 'SYSTEM',
            JSON_OBJECT('dni', OLD.dni_conductor, 'nombre', OLD.nombre_conductor));
END$$

-- ============================================================================
-- TRIGGERS: TRACTO
-- ============================================================================

DROP TRIGGER IF EXISTS trg_tracto_after_insert$$
CREATE TRIGGER trg_tracto_after_insert
AFTER INSERT ON tracto
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
        VALUES ('tracto', 'INSERT', NEW.placa_tracto, 'SYSTEM',
                JSON_OBJECT('placa', NEW.placa_tracto, 'marca', NEW.marca_unidad, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_tracto_after_update$$
CREATE TRIGGER trg_tracto_after_update
AFTER UPDATE ON tracto
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
        VALUES ('tracto', 'UPDATE', NEW.placa_tracto, 'SYSTEM',
                JSON_OBJECT('placa', OLD.placa_tracto, 'marca', OLD.marca_unidad, 'activo', OLD.activo),
                JSON_OBJECT('placa', NEW.placa_tracto, 'marca', NEW.marca_unidad, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_tracto_after_delete$$
CREATE TRIGGER trg_tracto_after_delete
AFTER DELETE ON tracto
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old)
    VALUES ('tracto', 'DELETE', OLD.placa_tracto, 'SYSTEM',
            JSON_OBJECT('placa', OLD.placa_tracto, 'marca', OLD.marca_unidad));
END$$

-- ============================================================================
-- TRIGGERS: PRODUCTO
-- ============================================================================

DROP TRIGGER IF EXISTS trg_producto_after_insert$$
CREATE TRIGGER trg_producto_after_insert
AFTER INSERT ON producto
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
        VALUES ('producto', 'INSERT', NEW.codigo_producto, 'SYSTEM',
                JSON_OBJECT('codigo', NEW.codigo_producto, 'descripcion', NEW.descripcion, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_producto_after_update$$
CREATE TRIGGER trg_producto_after_update
AFTER UPDATE ON producto
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
        VALUES ('producto', 'UPDATE', NEW.codigo_producto, 'SYSTEM',
                JSON_OBJECT('codigo', OLD.codigo_producto, 'descripcion', OLD.descripcion, 'activo', OLD.activo),
                JSON_OBJECT('codigo', NEW.codigo_producto, 'descripcion', NEW.descripcion, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_producto_after_delete$$
CREATE TRIGGER trg_producto_after_delete
AFTER DELETE ON producto
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old)
    VALUES ('producto', 'DELETE', OLD.codigo_producto, 'SYSTEM',
            JSON_OBJECT('codigo', OLD.codigo_producto, 'descripcion', OLD.descripcion));
END$$

-- ============================================================================
-- TRIGGERS: GUIA_REMITENTE
-- ============================================================================

DROP TRIGGER IF EXISTS trg_guia_remitente_after_insert$$
CREATE TRIGGER trg_guia_remitente_after_insert
AFTER INSERT ON guia_remitente
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
        VALUES ('guia_remitente', 'INSERT', NEW.numero_guia_remitente, 'SYSTEM',
                JSON_OBJECT('numero', NEW.numero_guia_remitente, 'remitente', NEW.ruc_remitente, 
                            'destinatario', NEW.ruc_destinatario, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_guia_remitente_after_update$$
CREATE TRIGGER trg_guia_remitente_after_update
AFTER UPDATE ON guia_remitente
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
        VALUES ('guia_remitente', 'UPDATE', NEW.numero_guia_remitente, 'SYSTEM',
                JSON_OBJECT('numero', OLD.numero_guia_remitente, 'peso_total', OLD.peso_total_traslado, 
                            'guia_transportista', OLD.numero_guia_transportista, 'activo', OLD.activo),
                JSON_OBJECT('numero', NEW.numero_guia_remitente, 'peso_total', NEW.peso_total_traslado,
                            'guia_transportista', NEW.numero_guia_transportista, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_guia_remitente_after_delete$$
CREATE TRIGGER trg_guia_remitente_after_delete
AFTER DELETE ON guia_remitente
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old)
    VALUES ('guia_remitente', 'DELETE', OLD.numero_guia_remitente, 'SYSTEM',
            JSON_OBJECT('numero', OLD.numero_guia_remitente, 'remitente', OLD.ruc_remitente));
END$$

-- ============================================================================
-- TRIGGERS: GUIA_TRANSPORTISTA
-- ============================================================================

DROP TRIGGER IF EXISTS trg_guia_transportista_after_insert$$
CREATE TRIGGER trg_guia_transportista_after_insert
AFTER INSERT ON guia_transportista
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
        VALUES ('guia_transportista', 'INSERT', NEW.numero_guia_transportista, 'SYSTEM',
                JSON_OBJECT('numero', NEW.numero_guia_transportista, 'transportista', NEW.ruc_transportista,
                            'peso_total', NEW.peso_bruto_total, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_guia_transportista_after_update$$
CREATE TRIGGER trg_guia_transportista_after_update
AFTER UPDATE ON guia_transportista
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
        VALUES ('guia_transportista', 'UPDATE', NEW.numero_guia_transportista, 'SYSTEM',
                JSON_OBJECT('numero', OLD.numero_guia_transportista, 'peso_total', OLD.peso_bruto_total, 'activo', OLD.activo),
                JSON_OBJECT('numero', NEW.numero_guia_transportista, 'peso_total', NEW.peso_bruto_total, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_guia_transportista_after_delete$$
CREATE TRIGGER trg_guia_transportista_after_delete
AFTER DELETE ON guia_transportista
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old)
    VALUES ('guia_transportista', 'DELETE', OLD.numero_guia_transportista, 'SYSTEM',
            JSON_OBJECT('numero', OLD.numero_guia_transportista, 'transportista', OLD.ruc_transportista));
END$$

-- ============================================================================
-- TRIGGERS: DETALLE_GUIA_REMITENTE
-- ============================================================================

DROP TRIGGER IF EXISTS trg_detalle_after_insert$$
CREATE TRIGGER trg_detalle_after_insert
AFTER INSERT ON detalle_guia_remitente
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
        VALUES ('detalle_guia_remitente', 'INSERT', CONCAT(NEW.numero_guia_remitente, '-', NEW.numero_item), 'SYSTEM',
                JSON_OBJECT('guia', NEW.numero_guia_remitente, 'item', NEW.numero_item, 
                            'producto', NEW.codigo_producto, 'peso_bruto', NEW.peso_bruto, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_detalle_after_update$$
CREATE TRIGGER trg_detalle_after_update
AFTER UPDATE ON detalle_guia_remitente
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
        VALUES ('detalle_guia_remitente', 'UPDATE', CONCAT(NEW.numero_guia_remitente, '-', NEW.numero_item), 'SYSTEM',
                JSON_OBJECT('producto', OLD.codigo_producto, 'peso_bruto', OLD.peso_bruto, 'activo', OLD.activo),
                JSON_OBJECT('producto', NEW.codigo_producto, 'peso_bruto', NEW.peso_bruto, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_detalle_after_delete$$
CREATE TRIGGER trg_detalle_after_delete
AFTER DELETE ON detalle_guia_remitente
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old)
    VALUES ('detalle_guia_remitente', 'DELETE', CONCAT(OLD.numero_guia_remitente, '-', OLD.numero_item), 'SYSTEM',
            JSON_OBJECT('guia', OLD.numero_guia_remitente, 'item', OLD.numero_item, 'producto', OLD.codigo_producto));
END$$

-- ============================================================================
-- TRIGGERS: INFO_TRANSPORTE
-- ============================================================================

DROP TRIGGER IF EXISTS trg_info_transporte_after_insert$$
CREATE TRIGGER trg_info_transporte_after_insert
AFTER INSERT ON info_transporte
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
        VALUES ('info_transporte', 'INSERT', NEW.id_info_transporte, 'SYSTEM',
                JSON_OBJECT('id', NEW.id_info_transporte, 'guia', NEW.numero_guia_transportista,
                            'conductor', NEW.dni_conductor, 'tracto', NEW.placa_tracto, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_info_transporte_after_update$$
CREATE TRIGGER trg_info_transporte_after_update
AFTER UPDATE ON info_transporte
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
        VALUES ('info_transporte', 'UPDATE', NEW.id_info_transporte, 'SYSTEM',
                JSON_OBJECT('conductor', OLD.dni_conductor, 'tracto', OLD.placa_tracto, 'activo', OLD.activo),
                JSON_OBJECT('conductor', NEW.dni_conductor, 'tracto', NEW.placa_tracto, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_info_transporte_after_delete$$
CREATE TRIGGER trg_info_transporte_after_delete
AFTER DELETE ON info_transporte
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old)
    VALUES ('info_transporte', 'DELETE', OLD.id_info_transporte, 'SYSTEM',
            JSON_OBJECT('id', OLD.id_info_transporte, 'guia', OLD.numero_guia_transportista));
END$$

-- ============================================================================
-- TRIGGERS: SEMIRREMOLQUE
-- ============================================================================

DROP TRIGGER IF EXISTS trg_semirremolque_after_insert$$
CREATE TRIGGER trg_semirremolque_after_insert
AFTER INSERT ON semirremolque
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
        VALUES ('semirremolque', 'INSERT', NEW.placa_semirremolque, 'SYSTEM',
                JSON_OBJECT('placa', NEW.placa_semirremolque, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_semirremolque_after_update$$
CREATE TRIGGER trg_semirremolque_after_update
AFTER UPDATE ON semirremolque
FOR EACH ROW
BEGIN
    IF @sp_audited IS NULL OR @sp_audited = 0 THEN
        INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
        VALUES ('semirremolque', 'UPDATE', NEW.placa_semirremolque, 'SYSTEM',
                JSON_OBJECT('placa', OLD.placa_semirremolque, 'activo', OLD.activo),
                JSON_OBJECT('placa', NEW.placa_semirremolque, 'activo', NEW.activo));
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_semirremolque_after_delete$$
CREATE TRIGGER trg_semirremolque_after_delete
AFTER DELETE ON semirremolque
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old)
    VALUES ('semirremolque', 'DELETE', OLD.placa_semirremolque, 'SYSTEM',
            JSON_OBJECT('placa', OLD.placa_semirremolque));
END$$

DELIMITER ;

-- ============================================================================
-- FIN DE TRIGGERS
-- ============================================================================
