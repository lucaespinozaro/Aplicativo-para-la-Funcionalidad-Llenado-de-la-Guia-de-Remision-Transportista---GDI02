-- ============================================================================
-- PROCEDIMIENTOS ALMACENADOS - SISTEMA GUÍA TRANSPORTISTA
-- Versión: 1.0
-- Requisito: Todas las mutaciones deben hacerse por SP
-- Convención: sp_<entidad>_<accion>
-- Parámetro obligatorio: p_usuario VARCHAR(100) para auditoría
-- ============================================================================

USE transportista;

DELIMITER $$

-- ============================================================================
-- MAESTRO: EMPRESA
-- ============================================================================

-- Insertar empresa
DROP PROCEDURE IF EXISTS sp_empresa_insert$$
CREATE PROCEDURE sp_empresa_insert(
IN p_ruc CHAR(11),
IN p_provincia VARCHAR(50),
IN p_departamento VARCHAR(50),
IN p_distrito VARCHAR(50),
IN p_domicilio VARCHAR(200),
IN p_razon_social VARCHAR(150),
IN p_usuario VARCHAR(100)
)
BEGIN
-- Validación RUC
IF p_ruc NOT REGEXP '^[0-9]{11}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RUC es 11 dígitos numérixcos';
END IF;

-- Validación campos
IF TRIM(p_razon_social) = '' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Razón social es obligatoria';
END IF;

-- Insertar
INSERT INTO empresa (ruc, provincia, departamento, distrito, domicilio, razon_social, activo)
VALUES (p_ruc, p_provincia, p_departamento, p_distrito, p_domicilio, p_razon_social, 1);

-- Auditoría
INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
VALUES ('empresa', 'INSERT', p_ruc, p_usuario, 
JSON_OBJECT('ruc', p_ruc, 'razon_social', p_razon_social, 'activo', 1));

SELECT 'OK' AS status, 'Empresa creada exitosamente' AS mensaje, p_ruc AS ruc;
END$$

-- Actualizar empresa
DROP PROCEDURE IF EXISTS sp_empresa_update$$
CREATE PROCEDURE sp_empresa_update(
IN p_ruc CHAR(11),
IN p_provincia VARCHAR(50),
IN p_departamento VARCHAR(50),
IN p_distrito VARCHAR(50),
IN p_domicilio VARCHAR(200),
IN p_razon_social VARCHAR(150),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

-- Validar existencia
IF NOT EXISTS (SELECT 1 FROM empresa WHERE ruc = p_ruc AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Empresa no existe o está inactiva';
END IF;

-- Capturar para auditoria
SELECT JSON_OBJECT('ruc', ruc, 'razon_social', razon_social, 'provincia', provincia,
'departamento', departamento, 'distrito', distrito, 'domicilio', domicilio)
INTO v_old_data
FROM empresa WHERE ruc = p_ruc;

-- Actualizar
UPDATE empresa 
SET provincia = p_provincia,
departamento = p_departamento,
distrito = p_distrito,
domicilio = p_domicilio,
razon_social = p_razon_social
WHERE ruc = p_ruc;

-- Auditoría
INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('empresa', 'UPDATE', p_ruc, p_usuario, v_old_data,
JSON_OBJECT('ruc', p_ruc, 'razon_social', p_razon_social, 'provincia', p_provincia));

SELECT 'OK' AS status, 'Empresa actualizada exitosamente' AS mensaje;
END$$

-- Borrado lógico empresa
DROP PROCEDURE IF EXISTS sp_empresa_soft_delete$$
CREATE PROCEDURE sp_empresa_soft_delete(
IN p_ruc CHAR(11),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

IF NOT EXISTS (SELECT 1 FROM empresa WHERE ruc = p_ruc AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Empresa no existe o ya está inactiva';
END IF;

SELECT JSON_OBJECT('ruc', ruc, 'razon_social', razon_social, 'activo', activo)
INTO v_old_data
FROM empresa WHERE ruc = p_ruc;

UPDATE empresa SET activo = 0 WHERE ruc = p_ruc;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('empresa', 'DELETE', p_ruc, p_usuario, v_old_data, JSON_OBJECT('activo', 0));

SELECT 'OK' AS status, 'Empresa desactivada exitosamente' AS mensaje;
END$$

-- ============================================================================
-- MAESTRO: CONDUCTOR
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_conductor_insert$$
CREATE PROCEDURE sp_conductor_insert(
IN p_dni_conductor CHAR(8),
IN p_nombre_conductor VARCHAR(150),
IN p_numero_licencia_conductor VARCHAR(9),
IN p_usuario VARCHAR(100)
)
BEGIN
-- Validación DNI (8 dígitos)
IF p_dni_conductor NOT REGEXP '^[0-9]{8}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DNI debe tener exactamente 8 dígitos numéricos';
END IF;

IF TRIM(p_nombre_conductor) = '' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre de conductor es obligatorio';
END IF;

INSERT INTO conductor (dni_conductor, nombre_conductor, numero_licencia_conductor, activo)
VALUES (p_dni_conductor, p_nombre_conductor, p_numero_licencia_conductor, 1);

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
VALUES ('conductor', 'INSERT', p_dni_conductor, p_usuario,
JSON_OBJECT('dni', p_dni_conductor, 'nombre', p_nombre_conductor, 'activo', 1));

SELECT 'OK' AS status, 'Conductor creado exitosamente' AS mensaje, p_dni_conductor AS dni;
END$$

DROP PROCEDURE IF EXISTS sp_conductor_update$$
CREATE PROCEDURE sp_conductor_update(
IN p_dni_conductor CHAR(8),
IN p_nombre_conductor VARCHAR(150),
IN p_numero_licencia_conductor VARCHAR(9),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

IF NOT EXISTS (SELECT 1 FROM conductor WHERE dni_conductor = p_dni_conductor AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Conductor no existe o está inactivo';
END IF;

SELECT JSON_OBJECT('dni', dni_conductor, 'nombre', nombre_conductor, 'licencia', numero_licencia_conductor)
INTO v_old_data
FROM conductor WHERE dni_conductor = p_dni_conductor;

UPDATE conductor 
SET nombre_conductor = p_nombre_conductor,
numero_licencia_conductor = p_numero_licencia_conductor
WHERE dni_conductor = p_dni_conductor;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('conductor', 'UPDATE', p_dni_conductor, p_usuario, v_old_data,
JSON_OBJECT('dni', p_dni_conductor, 'nombre', p_nombre_conductor, 'licencia', p_numero_licencia_conductor));

SELECT 'OK' AS status, 'Conductor actualizado exitosamente' AS mensaje;
END$$

DROP PROCEDURE IF EXISTS sp_conductor_soft_delete$$
CREATE PROCEDURE sp_conductor_soft_delete(
IN p_dni_conductor CHAR(8),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

IF NOT EXISTS (SELECT 1 FROM conductor WHERE dni_conductor = p_dni_conductor AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Conductor no existe o ya está inactivo';
END IF;

SELECT JSON_OBJECT('dni', dni_conductor, 'nombre', nombre_conductor, 'activo', activo)
INTO v_old_data
FROM conductor WHERE dni_conductor = p_dni_conductor;

UPDATE conductor SET activo = 0 WHERE dni_conductor = p_dni_conductor;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('conductor', 'DELETE', p_dni_conductor, p_usuario, v_old_data, JSON_OBJECT('activo', 0));

SELECT 'OK' AS status, 'Conductor desactivado exitosamente' AS mensaje;
END$$

-- ============================================================================
-- MAESTRO: TRACTO
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_tracto_insert$$
CREATE PROCEDURE sp_tracto_insert(
IN p_placa_tracto CHAR(6),
IN p_marca_unidad VARCHAR(50),
IN p_certificado_inscripcion CHAR(12),
IN p_usuario VARCHAR(100)
)
BEGIN
IF TRIM(p_placa_tracto) = '' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Placa de tracto es obligatoria';
END IF;

INSERT INTO tracto (placa_tracto, marca_unidad, certificado_inscripcion, activo)
VALUES (p_placa_tracto, p_marca_unidad, p_certificado_inscripcion, 1);

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
VALUES ('tracto', 'INSERT', p_placa_tracto, p_usuario,
JSON_OBJECT('placa', p_placa_tracto, 'marca', p_marca_unidad, 'activo', 1));

SELECT 'OK' AS status, 'Tracto creado exitosamente' AS mensaje, p_placa_tracto AS placa;
END$$

DROP PROCEDURE IF EXISTS sp_tracto_update$$
CREATE PROCEDURE sp_tracto_update(
IN p_placa_tracto CHAR(6),
IN p_marca_unidad VARCHAR(50),
IN p_certificado_inscripcion CHAR(12),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

IF NOT EXISTS (SELECT 1 FROM tracto WHERE placa_tracto = p_placa_tracto AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tracto no existe o está inactivo';
END IF;

SELECT JSON_OBJECT('placa', placa_tracto, 'marca', marca_unidad, 'certificado', certificado_inscripcion)
INTO v_old_data
FROM tracto WHERE placa_tracto = p_placa_tracto;

UPDATE tracto 
SET marca_unidad = p_marca_unidad,
certificado_inscripcion = p_certificado_inscripcion
WHERE placa_tracto = p_placa_tracto;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('tracto', 'UPDATE', p_placa_tracto, p_usuario, v_old_data,
JSON_OBJECT('placa', p_placa_tracto, 'marca', p_marca_unidad, 'certificado', p_certificado_inscripcion));

SELECT 'OK' AS status, 'Tracto actualizado exitosamente' AS mensaje;
END$$

DROP PROCEDURE IF EXISTS sp_tracto_soft_delete$$
CREATE PROCEDURE sp_tracto_soft_delete(
IN p_placa_tracto CHAR(6),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

IF NOT EXISTS (SELECT 1 FROM tracto WHERE placa_tracto = p_placa_tracto AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tracto no existe o ya está inactivo';
END IF;

SELECT JSON_OBJECT('placa', placa_tracto, 'activo', activo)
INTO v_old_data
FROM tracto WHERE placa_tracto = p_placa_tracto;

UPDATE tracto SET activo = 0 WHERE placa_tracto = p_placa_tracto;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('tracto', 'DELETE', p_placa_tracto, p_usuario, v_old_data, JSON_OBJECT('activo', 0));

SELECT 'OK' AS status, 'Tracto desactivado exitosamente' AS mensaje;
END$$

-- ============================================================================
-- MAESTRO: SEMIRREMOLQUE
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_semirremolque_insert$$
CREATE PROCEDURE sp_semirremolque_insert(
IN p_placa_semirremolque CHAR(6),
IN p_certificado_inscripcion_semiremolque CHAR(12),
IN p_usuario VARCHAR(100)
)
BEGIN
IF TRIM(p_placa_semirremolque) = '' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Placa de semirremolque es obligatoria';
END IF;

INSERT INTO semirremolque (placa_semirremolque, certificado_inscripcion_semiremolque, activo)
VALUES (p_placa_semirremolque, p_certificado_inscripcion_semiremolque, 1);

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
VALUES ('semirremolque', 'INSERT', p_placa_semirremolque, p_usuario,
JSON_OBJECT('placa', p_placa_semirremolque, 'activo', 1));

SELECT 'OK' AS status, 'Semirremolque creado exitosamente' AS mensaje, p_placa_semirremolque AS placa;
END$$

DROP PROCEDURE IF EXISTS sp_semirremolque_update$$
CREATE PROCEDURE sp_semirremolque_update(
IN p_placa_semirremolque CHAR(6),
IN p_certificado_inscripcion_semiremolque CHAR(12),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

IF NOT EXISTS (SELECT 1 FROM semirremolque WHERE placa_semirremolque = p_placa_semirremolque AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Semirremolque no existe o está inactivo';
END IF;

SELECT JSON_OBJECT('placa', placa_semirremolque, 'certificado', certificado_inscripcion_semiremolque)
INTO v_old_data
FROM semirremolque WHERE placa_semirremolque = p_placa_semirremolque;

UPDATE semirremolque 
SET certificado_inscripcion_semiremolque = p_certificado_inscripcion_semiremolque
WHERE placa_semirremolque = p_placa_semirremolque;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('semirremolque', 'UPDATE', p_placa_semirremolque, p_usuario, v_old_data,
JSON_OBJECT('placa', p_placa_semirremolque, 'certificado', p_certificado_inscripcion_semiremolque));

SELECT 'OK' AS status, 'Semirremolque actualizado exitosamente' AS mensaje;
END$$

DROP PROCEDURE IF EXISTS sp_semirremolque_soft_delete$$
CREATE PROCEDURE sp_semirremolque_soft_delete(
IN p_placa_semirremolque CHAR(6),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

IF NOT EXISTS (SELECT 1 FROM semirremolque WHERE placa_semirremolque = p_placa_semirremolque AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Semirremolque no existe o ya está inactivo';
END IF;

SELECT JSON_OBJECT('placa', placa_semirremolque, 'activo', activo)
INTO v_old_data
FROM semirremolque WHERE placa_semirremolque = p_placa_semirremolque;

UPDATE semirremolque SET activo = 0 WHERE placa_semirremolque = p_placa_semirremolque;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('semirremolque', 'DELETE', p_placa_semirremolque, p_usuario, v_old_data, JSON_OBJECT('activo', 0));

SELECT 'OK' AS status, 'Semirremolque desactivado exitosamente' AS mensaje;
END$$

-- ============================================================================
-- MAESTRO: PRODUCTO
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_producto_insert$$
CREATE PROCEDURE sp_producto_insert(
IN p_codigo_producto CHAR(20),
IN p_lote CHAR(20),
IN p_descripcion VARCHAR(200),
IN p_material VARCHAR(50),
IN p_unidad_medida VARCHAR(10),
IN p_peso_bruto DECIMAL(12,3),
IN p_usuario VARCHAR(100)
)
BEGIN
IF p_peso_bruto < 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Peso bruto no puede ser negativo';
END IF;

IF TRIM(p_descripcion) = '' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Descripción es obligatoria';
END IF;

INSERT INTO producto (codigo_producto, lote, descripcion, material, unidad_medida, peso_bruto, activo)
VALUES (p_codigo_producto, p_lote, p_descripcion, p_material, p_unidad_medida, p_peso_bruto, 1);

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
VALUES ('producto', 'INSERT', p_codigo_producto, p_usuario,
JSON_OBJECT('codigo', p_codigo_producto, 'descripcion', p_descripcion, 'activo', 1));

SELECT 'OK' AS status, 'Producto creado exitosamente' AS mensaje, p_codigo_producto AS codigo;
END$$

DROP PROCEDURE IF EXISTS sp_producto_update$$
CREATE PROCEDURE sp_producto_update(
IN p_codigo_producto CHAR(20),
IN p_lote CHAR(20),
IN p_descripcion VARCHAR(200),
IN p_material VARCHAR(50),
IN p_unidad_medida VARCHAR(10),
IN p_peso_bruto DECIMAL(12,3),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

IF NOT EXISTS (SELECT 1 FROM producto WHERE codigo_producto = p_codigo_producto AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe o está inactivo';
END IF;

IF p_peso_bruto < 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Peso bruto no puede ser negativo';
END IF;

SELECT JSON_OBJECT('codigo', codigo_producto, 'descripcion', descripcion, 'peso_bruto', peso_bruto)
INTO v_old_data
FROM producto WHERE codigo_producto = p_codigo_producto;

UPDATE producto 
SET lote = p_lote,
descripcion = p_descripcion,
material = p_material,
unidad_medida = p_unidad_medida,
peso_bruto = p_peso_bruto
WHERE codigo_producto = p_codigo_producto;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('producto', 'UPDATE', p_codigo_producto, p_usuario, v_old_data,
JSON_OBJECT('codigo', p_codigo_producto, 'descripcion', p_descripcion, 'peso_bruto', p_peso_bruto));

SELECT 'OK' AS status, 'Producto actualizado exitosamente' AS mensaje;
END$$

DROP PROCEDURE IF EXISTS sp_producto_soft_delete$$
CREATE PROCEDURE sp_producto_soft_delete(
IN p_codigo_producto CHAR(20),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

IF NOT EXISTS (SELECT 1 FROM producto WHERE codigo_producto = p_codigo_producto AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe o ya está inactivo';
END IF;

SELECT JSON_OBJECT('codigo', codigo_producto, 'descripcion', descripcion, 'activo', activo)
INTO v_old_data
FROM producto WHERE codigo_producto = p_codigo_producto;

UPDATE producto SET activo = 0 WHERE codigo_producto = p_codigo_producto;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('producto', 'DELETE', p_codigo_producto, p_usuario, v_old_data, JSON_OBJECT('activo', 0));

SELECT 'OK' AS status, 'Producto desactivado exitosamente' AS mensaje;
END$$

-- ============================================================================
-- GUÍA REMITENTE: GUARDAR BORRADOR
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_gr_save_draft$$
CREATE PROCEDURE sp_gr_save_draft(
IN p_numero_guia_remitente CHAR(20),
IN p_ruc_transportista CHAR(11),
IN p_ruc_destinatario CHAR(11),
IN p_ruc_remitente CHAR(11),
IN p_cod_local_llegada VARCHAR(10),
IN p_cod_local_partida VARCHAR(10),
IN p_fecha_entrega_bienes DATE,
IN p_modalidad_traslado VARCHAR(30),
IN p_hora_emision TIME,
IN p_fecha_emision DATE,
IN p_motivo_traslado VARCHAR(200),
IN p_observaciones VARCHAR(500),
IN p_peso_total_traslado DECIMAL(14,3),
IN p_dni_conductor CHAR(8),
IN p_placa_tracto CHAR(6),
IN p_usuario VARCHAR(100)
)
BEGIN
-- Validaciones
IF p_ruc_transportista NOT REGEXP '^[0-9]{11}$' OR p_ruc_destinatario NOT REGEXP '^[0-9]{11}$' OR p_ruc_remitente NOT REGEXP '^[0-9]{11}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RUC inválido (debe ser 11 dígitos)';
END IF;

IF p_dni_conductor NOT REGEXP '^[0-9]{8}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DNI inválido (debe ser 8 dígitos)';
END IF;

IF p_peso_total_traslado < 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Peso total no puede ser negativo';
END IF;

-- Validar que empresas existan y estén activas
IF NOT EXISTS (SELECT 1 FROM empresa WHERE ruc = p_ruc_transportista AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transportista no existe o está inactivo';
END IF;

IF NOT EXISTS (SELECT 1 FROM empresa WHERE ruc = p_ruc_destinatario AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destinatario no existe o está inactivo';
END IF;

IF NOT EXISTS (SELECT 1 FROM empresa WHERE ruc = p_ruc_remitente AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Remitente no existe o está inactivo';
END IF;

-- Validar conductor activo
IF NOT EXISTS (SELECT 1 FROM conductor WHERE dni_conductor = p_dni_conductor AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Conductor no existe o está inactivo';
END IF;

-- Validar tracto activo
IF NOT EXISTS (SELECT 1 FROM tracto WHERE placa_tracto = p_placa_tracto AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tracto no existe o está inactivo';
END IF;

-- Insertar guía remitente (borrador)
INSERT INTO guia_remitente (
numero_guia_remitente, ruc_transportista, ruc_destinatario, ruc_remitente,
cod_local_llegada, cod_local_partida, fecha_entrega_bienes, modalidad_traslado,
hora_emision, fecha_emision, motivo_traslado, observaciones, peso_total_traslado,
dni_conductor, placa_tracto, activo
) VALUES (
p_numero_guia_remitente, p_ruc_transportista, p_ruc_destinatario, p_ruc_remitente,
p_cod_local_llegada, p_cod_local_partida, p_fecha_entrega_bienes, p_modalidad_traslado,
p_hora_emision, p_fecha_emision, p_motivo_traslado, p_observaciones, p_peso_total_traslado,
p_dni_conductor, p_placa_tracto, 1
);

-- Auditoría
INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
VALUES ('guia_remitente', 'INSERT', p_numero_guia_remitente, p_usuario,
JSON_OBJECT('numero', p_numero_guia_remitente, 'ruc_remitente', p_ruc_remitente, 'estado', 'BORRADOR'));

SELECT 'OK' AS status, 'Guía remitente guardada como borrador' AS mensaje, p_numero_guia_remitente AS numero_guia;
END$$

-- ============================================================================
-- DETALLE GUÍA REMITENTE: INSERT
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_detalle_insert$$
CREATE PROCEDURE sp_detalle_insert(
IN p_numero_guia_remitente CHAR(20),
IN p_numero_item INT,
IN p_codigo_producto CHAR(20),
IN p_peso_tara DECIMAL(12,3),
IN p_peso_neto DECIMAL(12,3),
IN p_peso_bruto DECIMAL(12,3),
IN p_usuario VARCHAR(100)
)
BEGIN
-- Validaciones de peso
IF p_peso_tara < 0 OR p_peso_neto < 0 OR p_peso_bruto < 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los pesos no pueden ser negativos';
END IF;

IF p_numero_item <= 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Número de ítem debe ser mayor a 0';
END IF;

-- Validar que la guía remitente exista
IF NOT EXISTS (SELECT 1 FROM guia_remitente WHERE numero_guia_remitente = p_numero_guia_remitente AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Guía remitente no existe o está inactiva';
END IF;

-- Validar que el producto exista y esté activo
IF NOT EXISTS (SELECT 1 FROM producto WHERE codigo_producto = p_codigo_producto AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe o está inactivo';
END IF;

-- Insertar detalle
INSERT INTO detalle_guia_remitente (
numero_guia_remitente, numero_item, codigo_producto, peso_tara, peso_neto, peso_bruto, activo
) VALUES (
p_numero_guia_remitente, p_numero_item, p_codigo_producto, p_peso_tara, p_peso_neto, p_peso_bruto, 1
);

-- Auditoría
INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
VALUES ('detalle_guia_remitente', 'INSERT', CONCAT(p_numero_guia_remitente, '-', p_numero_item), p_usuario,
JSON_OBJECT('numero_guia', p_numero_guia_remitente, 'item', p_numero_item, 'producto', p_codigo_producto));

SELECT 'OK' AS status, 'Detalle agregado exitosamente' AS mensaje;
END$$

-- ============================================================================
-- DETALLE GUÍA REMITENTE: UPDATE
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_detalle_update$$
CREATE PROCEDURE sp_detalle_update(
IN p_numero_guia_remitente CHAR(20),
IN p_numero_item INT,
IN p_codigo_producto CHAR(20),
IN p_peso_tara DECIMAL(12,3),
IN p_peso_neto DECIMAL(12,3),
IN p_peso_bruto DECIMAL(12,3),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

-- Validaciones
IF p_peso_tara < 0 OR p_peso_neto < 0 OR p_peso_bruto < 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los pesos no pueden ser negativos';
END IF;

IF NOT EXISTS (SELECT 1 FROM detalle_guia_remitente WHERE numero_guia_remitente = p_numero_guia_remitente AND numero_item = p_numero_item AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Detalle no existe o está inactivo';
END IF;

IF NOT EXISTS (SELECT 1 FROM producto WHERE codigo_producto = p_codigo_producto AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe o está inactivo';
END IF;

SELECT JSON_OBJECT('numero_guia', numero_guia_remitente, 'item', numero_item, 'producto', codigo_producto, 'peso_bruto', peso_bruto)
INTO v_old_data
FROM detalle_guia_remitente WHERE numero_guia_remitente = p_numero_guia_remitente AND numero_item = p_numero_item;

UPDATE detalle_guia_remitente 
SET codigo_producto = p_codigo_producto,
peso_tara = p_peso_tara,
peso_neto = p_peso_neto,
peso_bruto = p_peso_bruto
WHERE numero_guia_remitente = p_numero_guia_remitente AND numero_item = p_numero_item;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('detalle_guia_remitente', 'UPDATE', CONCAT(p_numero_guia_remitente, '-', p_numero_item), p_usuario, v_old_data,
JSON_OBJECT('numero_guia', p_numero_guia_remitente, 'item', p_numero_item, 'producto', p_codigo_producto, 'peso_bruto', p_peso_bruto));

SELECT 'OK' AS status, 'Detalle actualizado exitosamente' AS mensaje;
END$$

-- ============================================================================
-- DETALLE GUÍA REMITENTE: SOFT DELETE
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_detalle_soft_delete$$
CREATE PROCEDURE sp_detalle_soft_delete(
IN p_numero_guia_remitente CHAR(20),
IN p_numero_item INT,
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

IF NOT EXISTS (SELECT 1 FROM detalle_guia_remitente WHERE numero_guia_remitente = p_numero_guia_remitente AND numero_item = p_numero_item AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Detalle no existe o ya está inactivo';
END IF;

SELECT JSON_OBJECT('numero_guia', numero_guia_remitente, 'item', numero_item, 'activo', activo)
INTO v_old_data
FROM detalle_guia_remitente WHERE numero_guia_remitente = p_numero_guia_remitente AND numero_item = p_numero_item;

UPDATE detalle_guia_remitente SET activo = 0 
WHERE numero_guia_remitente = p_numero_guia_remitente AND numero_item = p_numero_item;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('detalle_guia_remitente', 'DELETE', CONCAT(p_numero_guia_remitente, '-', p_numero_item), p_usuario, v_old_data, JSON_OBJECT('activo', 0));

SELECT 'OK' AS status, 'Detalle desactivado exitosamente' AS mensaje;
END$$

-- ============================================================================
-- GUÍA REMITENTE: FINALIZAR
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_gr_finalize$$
CREATE PROCEDURE sp_gr_finalize(
IN p_numero_guia CHAR(20),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_count_items INT;
DECLARE v_sum_peso DECIMAL(14,3);
DECLARE v_peso_total DECIMAL(14,3);

-- Validar existencia
IF NOT EXISTS (SELECT 1 FROM guia_remitente WHERE numero_guia_remitente = p_numero_guia AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Guía remitente no existe o está inactiva';
END IF;

-- Verificar que la guía no esté ya asignada a una GT
IF EXISTS (SELECT 1 FROM guia_remitente WHERE numero_guia_remitente = p_numero_guia AND numero_guia_transportista IS NOT NULL) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta guía ya está asignada a una Guía Transportista';
END IF;

-- Contar ítems activos
SELECT COUNT(*), COALESCE(SUM(peso_bruto), 0)
INTO v_count_items, v_sum_peso
FROM detalle_guia_remitente
WHERE numero_guia_remitente = p_numero_guia AND activo = 1;

IF v_count_items = 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La guía debe tener al menos un ítem activo';
END IF;

-- Obtener peso total declarado
SELECT peso_total_traslado INTO v_peso_total
FROM guia_remitente
WHERE numero_guia_remitente = p_numero_guia;

-- Comparar suma de ítems vs peso total (tolerancia 1%)
IF ABS(v_sum_peso - v_peso_total) > (v_peso_total * 0.01) THEN
-- Ajustar peso total automáticamente
UPDATE guia_remitente 
SET peso_total_traslado = v_sum_peso
WHERE numero_guia_remitente = p_numero_guia;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('guia_remitente', 'FINALIZE', p_numero_guia, p_usuario,
JSON_OBJECT('peso_total_original', v_peso_total),
JSON_OBJECT('peso_total_ajustado', v_sum_peso, 'estado', 'FINALIZADA'));

SELECT 'OK' AS status, 'Guía finalizada con ajuste de peso' AS mensaje, v_sum_peso AS peso_ajustado;
ELSE
INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
VALUES ('guia_remitente', 'FINALIZE', p_numero_guia, p_usuario,
JSON_OBJECT('estado', 'FINALIZADA', 'items_count', v_count_items));

SELECT 'OK' AS status, 'Guía finalizada exitosamente' AS mensaje;
END IF;
END$$

-- ============================================================================
-- INFO TRANSPORTE: INSERT
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_info_transporte_insert$$
CREATE PROCEDURE sp_info_transporte_insert(
IN p_numero_guia_transportista CHAR(20),
IN p_dni_conductor CHAR(8),
IN p_placa_tracto CHAR(6),
IN p_placa_semirremolque CHAR(6),
IN p_usuario VARCHAR(100)
)
BEGIN
-- Validar DNI
IF p_dni_conductor NOT REGEXP '^[0-9]{8}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DNI inválido (debe ser 8 dígitos)';
END IF;

-- Validar que guía transportista exista
IF NOT EXISTS (SELECT 1 FROM guia_transportista WHERE numero_guia_transportista = p_numero_guia_transportista AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Guía transportista no existe o está inactiva';
END IF;

-- Validar conductor activo
IF NOT EXISTS (SELECT 1 FROM conductor WHERE dni_conductor = p_dni_conductor AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Conductor no existe o está inactivo';
END IF;

-- Validar tracto activo
IF NOT EXISTS (SELECT 1 FROM tracto WHERE placa_tracto = p_placa_tracto AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tracto no existe o está inactivo';
END IF;

-- Validar semirremolque si se proporciona
IF p_placa_semirremolque IS NOT NULL AND p_placa_semirremolque != '' THEN
IF NOT EXISTS (SELECT 1 FROM semirremolque WHERE placa_semirremolque = p_placa_semirremolque AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Semirremolque no existe o está inactivo';
END IF;
END IF;

INSERT INTO info_transporte (numero_guia_transportista, dni_conductor, placa_tracto, placa_semirremolque, activo)
VALUES (p_numero_guia_transportista, p_dni_conductor, p_placa_tracto, p_placa_semirremolque, 1);

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
VALUES ('info_transporte', 'INSERT', LAST_INSERT_ID(), p_usuario,
JSON_OBJECT('guia_transportista', p_numero_guia_transportista, 'conductor', p_dni_conductor, 'tracto', p_placa_tracto));

SELECT 'OK' AS status, 'Info transporte creada exitosamente' AS mensaje, LAST_INSERT_ID() AS id_info;
END$$

DROP PROCEDURE IF EXISTS sp_info_transporte_soft_delete$$
CREATE PROCEDURE sp_info_transporte_soft_delete(
IN p_id_info_transporte INT,
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_old_data JSON;

IF NOT EXISTS (SELECT 1 FROM info_transporte WHERE id_info_transporte = p_id_info_transporte AND activo = 1) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Info transporte no existe o ya está inactiva';
END IF;

SELECT JSON_OBJECT('id', id_info_transporte, 'guia', numero_guia_transportista, 'activo', activo)
INTO v_old_data
FROM info_transporte WHERE id_info_transporte = p_id_info_transporte;

UPDATE info_transporte SET activo = 0 WHERE id_info_transporte = p_id_info_transporte;

INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_old, datos_new)
VALUES ('info_transporte', 'DELETE', p_id_info_transporte, p_usuario, v_old_data, JSON_OBJECT('activo', 0));

SELECT 'OK' AS status, 'Info transporte desactivada exitosamente' AS mensaje;
END$$

-- ============================================================================
-- GUÍA TRANSPORTISTA: CREAR DESDE REMITENTES (TRANSACCIONAL)
-- ============================================================================
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_gt_create_from_remitentes$$
CREATE PROCEDURE sp_gt_create_from_remitentes(
IN p_numero_guia_transportista CHAR(20),
IN p_remitentes_json JSON, -- Array de números de guía remitente: ["GR001","GR002"]
IN p_ruc_transportista CHAR(11),
IN p_ruc_subcontratado CHAR(11),
IN p_ruc_pagador_flete CHAR(11),
IN p_fecha_inicio_traslado DATE,
IN p_unidad_medida VARCHAR(10),
IN p_indicador_pagador_flete TINYINT,
IN p_indicador_transporte_subcontratado TINYINT,
IN p_indicador_transbordo_programado TINYINT,
IN p_indicador_retorno_vehiculo_vacio TINYINT,
IN p_indicador_retorno_envases_vacios TINYINT,
IN p_observaciones VARCHAR(500),
IN p_numero_registro_mtc VARCHAR(20),
IN p_usuario VARCHAR(100)
)
BEGIN
DECLARE v_peso_total DECIMAL(14,3) DEFAULT 0;
DECLARE v_idx INT DEFAULT 0;
DECLARE v_array_length INT;
DECLARE v_ruc_remitente CHAR(11);
DECLARE v_ruc_destinatario CHAR(11);
DECLARE v_numero_gr CHAR(50);
DECLARE v_temp_peso DECIMAL(14,3);

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al crear guía transportista: transacción revertida';
END;

START TRANSACTION;

-- Validar RUC transportista (si está vacío o NULL se puede ajustar según reglas)
IF p_ruc_transportista IS NULL OR p_ruc_transportista = '' OR p_ruc_transportista NOT REGEXP '^[0-9]{11}$' THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RUC transportista inválido';
END IF;

-- Validar JSON de remitentes
SET v_array_length = JSON_LENGTH(p_remitentes_json);
IF v_array_length IS NULL OR v_array_length = 0 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe proporcionar al menos una guía remitente';
END IF;

-- Iterar remitentes
WHILE v_idx < v_array_length DO
SET v_numero_gr = JSON_UNQUOTE(JSON_EXTRACT(p_remitentes_json, CONCAT('$[', v_idx, ']')));

-- Validaciones por remitente
IF NOT EXISTS (SELECT 1 FROM guia_remitente WHERE numero_guia_remitente = v_numero_gr AND activo = 1) THEN
SET @msg := CONCAT('Guía remitente ', v_numero_gr, ' no existe o está inactiva');
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
END IF;

IF EXISTS (SELECT 1 FROM guia_remitente WHERE numero_guia_remitente = v_numero_gr AND numero_guia_transportista IS NOT NULL) THEN
SET @msg := CONCAT('Guía remitente ', v_numero_gr, ' ya está asignada a otra GT');
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
END IF;

-- Tomamos RUC remitente/destinatario de la primera GR
IF v_idx = 0 THEN
SELECT ruc_remitente, ruc_destinatario
INTO v_ruc_remitente, v_ruc_destinatario
FROM guia_remitente
WHERE numero_guia_remitente = v_numero_gr;
END IF;

-- Sumar peso
SELECT peso_total_traslado INTO v_temp_peso
FROM guia_remitente
WHERE numero_guia_remitente = v_numero_gr;

SET v_peso_total = v_peso_total + COALESCE(v_temp_peso, 0);

SET v_idx = v_idx + 1;
END WHILE;

-- Insertar guía transportista
INSERT INTO guia_transportista (
numero_guia_transportista, fecha_emision, hora_emision, observaciones,
fecha_inicio_traslado, numero_registro_mtc, peso_bruto_total, unidad_medida_peso_bruto,
indicador_pagador_flete, indicador_transporte_subcontratado, indicador_transbordo_programado,
indicador_retorno_vehiculo_vacio, indicador_retorno_envases_vacios,
ruc_subcontratado, ruc_pagador_flete, ruc_transportista, ruc_remitente, ruc_destinatario, activo
) VALUES (
p_numero_guia_transportista, CURDATE(), CURTIME(), p_observaciones,
p_fecha_inicio_traslado, p_numero_registro_mtc, v_peso_total, p_unidad_medida,
p_indicador_pagador_flete, p_indicador_transporte_subcontratado, p_indicador_transbordo_programado,
p_indicador_retorno_vehiculo_vacio, p_indicador_retorno_envases_vacios,
p_ruc_subcontratado, p_ruc_pagador_flete, p_ruc_transportista, v_ruc_remitente, v_ruc_destinatario, 1
);

-- Actualizar cada guia_remitente con el numero de GT
SET v_idx = 0;
WHILE v_idx < v_array_length DO
SET v_numero_gr = JSON_UNQUOTE(JSON_EXTRACT(p_remitentes_json, CONCAT('$[', v_idx, ']')));

UPDATE guia_remitente
SET numero_guia_transportista = p_numero_guia_transportista
WHERE numero_guia_remitente = v_numero_gr;

SET v_idx = v_idx + 1;
END WHILE;

-- Auditoría
INSERT INTO audit_log (tabla_nombre, accion, registro_pk, usuario, datos_new)
VALUES ('guia_transportista', 'INSERT', p_numero_guia_transportista, p_usuario,
JSON_OBJECT('numero', p_numero_guia_transportista, 'remitentes', p_remitentes_json,
'peso_total', v_peso_total, 'transportista', p_ruc_transportista));

COMMIT;

SELECT 'OK' AS status, 'Guía transportista creada exitosamente' AS mensaje,
p_numero_guia_transportista AS numero, v_peso_total AS peso_total;
END$$

DELIMITER ;


-- ============================================================================
-- FIN DE PROCEDIMIENTOS
-- ============================================================================
