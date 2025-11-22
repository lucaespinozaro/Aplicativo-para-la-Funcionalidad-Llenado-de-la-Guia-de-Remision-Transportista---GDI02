-- ============================================================================
-- CREACIÓN DE LA BASE DE DATOS "TRANSPORTISTA"
-- ============================================================================
CREATE DATABASE IF NOT EXISTS transportista
DEFAULT CHARACTER SET = utf8mb4
DEFAULT COLLATE = utf8mb4_uca1400_ai_ci;
SET NAMES 'utf8mb4' COLLATE 'utf8mb4_uca1400_ai_ci';
SET collation_connection = 'utf8mb4_uca1400_ai_ci';
USE transportista;
-- CREACIÓN DE LA TABLA EMPRESA Y SUS INDICES
CREATE TABLE empresa 
(
ruc CHAR(11) NOT NULL,
provincia VARCHAR(50) NOT NULL,
departamento VARCHAR(50) NOT NULL,
distrito VARCHAR(50) NOT NULL,
domicilio VARCHAR(200) NOT NULL,
razon_social VARCHAR(150) NOT NULL,
PRIMARY KEY (ruc)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE INDEX idx_empresa_razon_social ON empresa(razon_social);
ALTER TABLE empresa
ADD CONSTRAINT chk_empresa_ruc_digits CHECK (ruc REGEXP '^[0-9]{11}$');

-- CREACIÓN DE LA TABLA CONDUCTOR Y SUS INDICES
CREATE TABLE conductor 
(
dni_conductor CHAR(8) NOT NULL,
nombre_conductor VARCHAR(150) NOT NULL,
numero_licencia_conductor VARCHAR(9) DEFAULT NULL,
PRIMARY KEY (dni_conductor)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE INDEX idx_conductor_nombre ON conductor(nombre_conductor);
CREATE UNIQUE INDEX uq_conductor_numero_licencia ON conductor(numero_licencia_conductor);
ALTER TABLE conductor
ADD CONSTRAINT chk_conductor_dni_digits CHECK (dni_conductor REGEXP '^[0-9]{8}$');

-- CREACIÓN DE LA TABLA TRACTO Y SUS INDICES
CREATE TABLE tracto 
(
placa_tracto CHAR(6) NOT NULL,
marca_unidad VARCHAR(50) DEFAULT NULL,
certificado_inscripcion CHAR(12) NOT NULL,
PRIMARY KEY (placa_tracto)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- CREACIÓN DE LA TABLA PRODUCTO Y SUS INDICES
CREATE TABLE producto
(
codigo_producto CHAR(20) NOT NULL,
lote CHAR(20) NOT NULL,
descripcion VARCHAR(200) NOT NULL,
material VARCHAR(50) DEFAULT NULL,
unidad_medida VARCHAR(10) NOT NULL,
peso_bruto DECIMAL(12,3) NOT NULL DEFAULT 0.000 CHECK (peso_bruto >= 0),
PRIMARY KEY (codigo_producto)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE FULLTEXT INDEX ft_producto_descripcion ON producto(descripcion);


-- CREACIÓN DE LA TABLA GUIA_TRANSPORTISTA  Y SUS INDICES
CREATE TABLE guia_transportista 
(
numero_guia_transportista CHAR(20) NOT NULL,
fecha_emision DATE NOT NULL,
hora_emision TIME NOT NULL,
observaciones VARCHAR(500) DEFAULT NULL,
fecha_inicio_traslado DATE NOT NULL,
numero_registro_mtc VARCHAR(20) DEFAULT NULL,
peso_bruto_total DECIMAL(14,3) NOT NULL CHECK (peso_bruto_total >= 0),
unidad_medida_peso_bruto VARCHAR(10) NOT NULL,
indicador_pagador_flete TINYINT(1) NOT NULL DEFAULT 0,
indicador_transporte_subcontratado TINYINT(1) NOT NULL DEFAULT 0,
indicador_transbordo_programado TINYINT(1) NOT NULL DEFAULT 0,
indicador_retorno_vehiculo_vacio TINYINT(1) NOT NULL DEFAULT 0,
indicador_retorno_envases_vacios TINYINT(1) NOT NULL DEFAULT 0,
ruc_subcontratado CHAR(11) DEFAULT NULL,
ruc_pagador_flete CHAR(11) DEFAULT NULL,
ruc_transportista CHAR(11) NOT NULL,
ruc_remitente CHAR(11) NOT NULL,
ruc_destinatario CHAR(11) NOT NULL,
PRIMARY KEY (numero_guia_transportista)
)
ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE INDEX idx_gt_fecha_emision ON guia_transportista(fecha_emision);
CREATE INDEX idx_gt_fecha_inicio ON guia_transportista(fecha_inicio_traslado);
CREATE INDEX idx_gt_RUC_transportista ON guia_transportista(ruc_transportista);
CREATE INDEX idx_gt_RUC_remitente ON guia_transportista(ruc_remitente);
CREATE INDEX idx_gt_RUC_destinatario ON guia_transportista(ruc_destinatario);
CREATE INDEX idx_gt_RUC_pagador ON guia_transportista(ruc_pagador_flete);
CREATE INDEX idx_gt_RUC_subcontratado ON guia_transportista(ruc_subcontratado);

ALTER TABLE guia_transportista
ADD CONSTRAINT fk_gt_ruc_transportista FOREIGN KEY (ruc_transportista) REFERENCES empresa(ruc),
ADD CONSTRAINT fk_gt_ruc_remitente FOREIGN KEY (ruc_remitente) REFERENCES empresa(ruc),
ADD CONSTRAINT fk_gt_ruc_destinatario FOREIGN KEY (ruc_destinatario) REFERENCES empresa(ruc),
ADD CONSTRAINT fk_gt_ruc_subcontratado FOREIGN KEY (ruc_subcontratado) REFERENCES empresa(ruc),
ADD CONSTRAINT fk_gt_ruc_pagador FOREIGN KEY (ruc_pagador_flete) REFERENCES empresa(ruc);

-- CREACIÓN DE LA TABLA GUI_REMITENTE Y SUS INDICES
CREATE TABLE guia_remitente 
(
numero_guia_remitente CHAR(20) NOT NULL,
numero_guia_transportista CHAR(20) DEFAULT NULL,
ruc_transportista CHAR(11) DEFAULT NULL,
ruc_destinatario CHAR(11) NOT NULL,
ruc_remitente CHAR(11) NOT NULL,
cod_local_llegada VARCHAR(10) NOT NULL,
cod_local_partida VARCHAR(10) NOT NULL,
fecha_entrega_bienes DATE NOT NULL,
modalidad_traslado VARCHAR(30) NOT NULL,
hora_emision TIME NOT NULL,
fecha_emision DATE NOT NULL,
motivo_traslado VARCHAR(200) DEFAULT NULL,
observaciones VARCHAR(500) DEFAULT NULL,
peso_total_traslado DECIMAL(14,3) NOT NULL CHECK (peso_total_traslado >= 0),
dni_conductor CHAR(8) NOT NULL,
placa_tracto CHAR(6) NOT NULL,
PRIMARY KEY (numero_guia_remitente)
)
ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE INDEX idx_gr_numero_gt ON guia_remitente(numero_guia_transportista);
CREATE INDEX idx_gr_RUC_transportista ON guia_remitente(ruc_transportista);
CREATE INDEX idx_gr_RUC_destinatario ON guia_remitente(ruc_destinatario);
CREATE INDEX idx_gr_RUC_remitente ON guia_remitente(ruc_remitente);
CREATE INDEX idx_gr_dni_conductor ON guia_remitente(dni_conductor);
CREATE INDEX idx_gr_placa_tracto ON guia_remitente(placa_tracto);
CREATE INDEX idx_gr_fecha_emision ON guia_remitente(fecha_emision);
CREATE INDEX idx_gr_fecha_entrega ON guia_remitente(fecha_entrega_bienes);

ALTER TABLE guia_remitente
ADD CONSTRAINT fk_gr_numero_gt FOREIGN KEY (numero_guia_transportista) REFERENCES guia_transportista(numero_guia_transportista),
ADD CONSTRAINT fk_gr_ruc_transportista FOREIGN KEY (ruc_transportista) REFERENCES empresa(ruc),
ADD CONSTRAINT fk_gr_ruc_destinatario FOREIGN KEY (ruc_destinatario) REFERENCES empresa(ruc),
ADD CONSTRAINT fk_gr_ruc_remitente FOREIGN KEY (ruc_remitente) REFERENCES empresa(ruc),
ADD CONSTRAINT fk_gr_dni_conductor FOREIGN KEY (dni_conductor) REFERENCES conductor(dni_conductor),
ADD CONSTRAINT fk_gr_placa_tracto FOREIGN KEY (placa_tracto) REFERENCES tracto(placa_tracto);

-- CREACIÓN DE LA TABLA SEMIRREMOLQUE Y SUS INDICES
CREATE TABLE semirremolque 
(
placa_semirremolque CHAR(6) NOT NULL,
numero_guia_remitente CHAR(20) DEFAULT NULL,
certificado_inscripcion_semiremolque CHAR(12) NOT NULL,
PRIMARY KEY (placa_semirremolque)
)
ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE INDEX idx_sem_numero_guia ON semirremolque(numero_guia_remitente);

ALTER TABLE semirremolque
ADD CONSTRAINT fk_sem_numero_guia FOREIGN KEY (numero_guia_remitente) REFERENCES guia_remitente(numero_guia_remitente);

-- CREACIÓN DE LA TABLA INFO_TRANSPORTE Y SUS INDICES
CREATE TABLE info_transporte 
(
id_info_transporte INT(10) NOT NULL AUTO_INCREMENT,
numero_guia_transportista CHAR(20) NOT NULL,
dni_conductor CHAR(8) NOT NULL,
placa_tracto CHAR(6) NOT NULL,
placa_semirremolque CHAR(6) DEFAULT NULL,
PRIMARY KEY (id_info_transporte)
)
ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE INDEX idx_info_numero_guia ON info_transporte(numero_guia_transportista);
CREATE INDEX idx_info_dni_conductor ON info_transporte(dni_conductor);
CREATE INDEX idx_info_placa_tracto ON info_transporte(placa_tracto);
CREATE INDEX idx_info_placa_semir ON info_transporte(placa_semirremolque);

ALTER TABLE info_transporte
ADD CONSTRAINT fk_info_numero_guia FOREIGN KEY (numero_guia_transportista) REFERENCES guia_transportista(numero_guia_transportista),
ADD CONSTRAINT fk_info_dni_conductor FOREIGN KEY (dni_conductor) REFERENCES conductor(dni_conductor),
ADD CONSTRAINT fk_info_placa_tracto FOREIGN KEY (placa_tracto) REFERENCES tracto(placa_tracto),
ADD CONSTRAINT fk_info_placa_semir FOREIGN KEY (placa_semirremolque) REFERENCES semirremolque(placa_semirremolque);

-- CREACIÓN DE LA TABLA INFO_TRANSPORTE Y SUS INDICES
CREATE TABLE detalle_guia_remitente 
(
numero_guia_remitente CHAR(20) NOT NULL,
numero_item INT(4) NOT NULL,
codigo_producto CHAR(20) NOT NULL,
peso_tara DECIMAL(12,3) NOT NULL DEFAULT 0.000,
peso_neto DECIMAL(12,3) NOT NULL DEFAULT 0.000,
peso_bruto DECIMAL(12,3) NOT NULL DEFAULT 0.000,
PRIMARY KEY (numero_guia_remitente, numero_item),
CONSTRAINT chk_det_numero_item_positive CHECK (numero_item > 0),
CONSTRAINT chk_det_pesos_nonneg CHECK (peso_tara >= 0 AND peso_neto >= 0 AND peso_bruto >= 0)
)
ENGINE=InnoDB ROW_FORMAT=DYNAMIC DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE INDEX idx_det_numero_guia ON detalle_guia_remitente(numero_guia_remitente);
CREATE INDEX idx_det_codigo_producto ON detalle_guia_remitente(codigo_producto);

ALTER TABLE detalle_guia_remitente
ADD CONSTRAINT fk_det_numero_guia FOREIGN KEY (numero_guia_remitente) REFERENCES guia_remitente(numero_guia_remitente),
ADD CONSTRAINT fk_det_codigo_producto FOREIGN KEY (codigo_producto) REFERENCES producto(codigo_producto);

-- CREACIÓN DE LA TABLA INFO_TRANSPORTE Y SUS INDICES
CREATE TABLE IF NOT EXISTS audit_log
(
id_audit INT AUTO_INCREMENT PRIMARY KEY,
tabla_nombre VARCHAR(100) NOT NULL,
accion VARCHAR(10) NOT NULL, 
registro_pk VARCHAR(200) NULL,
usuario VARCHAR(100) DEFAULT NULL,
fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
datos_old JSON NULL,
datos_new JSON NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

ALTER TABLE empresa ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE conductor ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE tracto ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE producto ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE guia_transportista ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE guia_remitente ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE semirremolque ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE info_transporte ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE detalle_guia_remitente ADD COLUMN IF NOT EXISTS activo TINYINT(1) NOT NULL DEFAULT 1;

-- ============================================================================
-- INSERCIONES EN LA BASE DE DATOS TRANSPORTISTA
-- ============================================================================
INSERT INTO empresa (ruc, provincia, departamento, distrito, domicilio, razon_social) VALUES
('20609911876', 'LIMA', 'LIMA', 'LIMA', 'AV. ARGENTINA NRO.778 INT. 1181', 'ADRISFERR PERU E.I.R.L.'),
('20602763103', 'LIMA', 'LIMA', 'SAN MARTIN DE PORRES', 'PROGRESO NRO. 450 MESA REDONDA', 'CONSTRUCTORA INTEGRAL LR S.A.C.'),
('20610463585', 'LIMA', 'LIMA', 'LIMA', 'AV. GUILLERMO DANSEY NRO. 360 INT. D01', 'MULTISERVICIOS INDUSTRIALES INOX E.I.R.L.'),
('20600813804', 'LIMA', 'LIMA', 'LURIGANCHO', 'CALLE HUARACAYO MZ. Z-4 LT. 1-A SECT. QUINTA ZONA', 'LEVAZ CONTRATISTAS GENERALES S.A.C.'),
('20509709573', 'AREQUIPA', 'AREQUIPA', 'TIABAYA', 'CAL.ISLAY S/N URB. PAMPAS NUEVAS ANEXO LOS TUNALES', 'ISOPETROL LUBRICANTS DEL PERU S.A.C.'),
('20497947384', 'AREQUIPA', 'AREQUIPA', 'CERRO COLORADO', 'VIA.EVITAMIENTO NRO. 420', 'PERU TRANSPORT S.R.L.'),
('20611606533', 'AREQUIPA', 'AREQUIPA', 'AREQUIPA', 'CAL. LOS TRANSPORTISTAS NRO. 250', 'CHALCOTTI GROUP S.A.C.'),
('20609392968', 'AREQUIPA', 'AREQUIPA', 'YURA', 'MZ. M LOTE. 1 URB. CIUDAD DE DIOS', '100 PORCIENTO S.A.C.'),
('20558165902', 'AREQUIPA', 'AREQUIPA', 'CERRO COLORADO', 'AV. EJERCITO NRO. 1025', 'FHA SOLUCIONES S.A.C.'),
('20556651508', 'LIMA', 'LIMA', 'ATE', 'CAL Los Tapiceros 00280', 'PARTS AND SERVICE ANADI E.I.R.L.'),
('20603171196', 'AREQUIPA', 'ISLAY', 'ISLAY', 'KM. 1 OTR. CARRETERA MATARANI - MOLLENDO', 'MAGOTTEAUX PERU S.A.C.'),
('20455870969', 'AREQUIPA', 'AREQUIPA', 'CERRO COLORADO', 'AV. AVIACION NRO. 890', 'AGZ TRANSPORTES S.A.C.'),
('20402885549', 'ANCASH', 'SANTA', 'CHIMBOTE', 'AV ANTUNEZ DE MAYOLO SN', 'EMPRESA SIDERURGICA DEL PERU S.A.A.'),
('20562926322', 'PUNO', 'CHUCUITO', 'DESAGUADERO', 'CARRETERA DESAGUADERO ILO KM 2', 'R. TRADING S.A.'),
('20307146798', 'LIMA', 'LIMA', 'LURIN', 'AV. INDUSTRIAL S/N - PRADERAS DE LURIN', 'CERAMICA SAN LORENZO S.A.C.'),
('20112273922', 'AREQUIPA', 'AREQUIPA', 'AREQUIPA', 'PAGO DE CHALLAMPA S/N', 'TIENDAS DEL MEJORAMIENTO DEL HOGAR S.A.'),
('20538428524', 'APURIMAC', 'COTABAMBAS', 'CHALLHUAHUACHO', 'LAS BAMBAS NRO. S/N, COM. CAMPESINA FUERABAMBA', 'MINERA LAS BAMBAS S.A');

INSERT INTO conductor (dni_conductor, nombre_conductor, numero_licencia_conductor) VALUES
('44140802', 'SANTOS RAMIREZ VICTOR', 'W44140802'),
('01491281', 'CONDORI CUTIPA WILFREDO', 'H01491281'),
('41013523', 'CRUZ MAMANI MARTIN ROLO', 'U41013523'),
('41741101', 'SULCA QUICO JESUS RODOLFO', 'H41741101'),
('40301032', 'IZQUIERDO GOMEZ MIGUEL ANGEL', 'Q40301032'),
('30674107', 'APAZA QUISPE ROMAN SANTOS', 'H30674107'),
('42567890', 'GARCIA FLORES JUAN CARLOS', 'H42567890'),
('43123456', 'LOPEZ CASTILLO PEDRO LUIS', 'U43123456'),
('29876543', 'QUISPE MAMANI JOSE ANTONIO', 'H29876543'),
('31234567', 'FERNANDEZ DIAZ MIGUEL ANGEL', 'Q31234567');

INSERT INTO tracto (placa_tracto, marca_unidad, certificado_inscripcion) VALUES
('1225YA', 'VOLVO', 'V1225YA20231'),
('VCT772', 'SCANIA', 'VVCT77220241'),
('V8B794', 'FREIGHTLINER', 'VV8B79420232'),
('V7L790', 'VOLVO', 'VV7L79020233'),
('V7L805', 'MERCEDES BENZ', 'VV7L80520234'),
('VCS902', 'SCANIA', 'VVCS90220235'),
('V9B123', 'VOLVO', 'VV9B12320236'),
('VCT885', 'INTERNATIONAL', 'VVCT88520237'),
('V6H456', 'SCANIA', 'VV6H45620238'),
('V8K789', 'FREIGHTLINER', 'VV8K78920239');


INSERT INTO producto (codigo_producto, lote, descripcion, material, unidad_medida, peso_bruto) VALUES
('PROD001', 'LT2025001', 'TUBO CUADRADO DE 4" X 4" X 4.5MM X 6M AC.', 'ACERO', 'NIU', 77.600),
('PROD002', 'LT2025002', 'TUBOS DE 2" C/R PVC PAVCO', 'PVC', 'NIU', 12.000),
('PROD003', 'LT2025003', 'MAXXOIL STAR MAXX PLUS DIESEL MULTIGRADO SAE 15W-40 (BAL 5GL)', 'ACEITE', 'BJ', 18.000),
('PROD004', 'LT2025004', 'UREA X LITRO', 'QUIMICO', 'LTR', 1.000),
('PROD005', 'LT2025005', 'KIT SECADOR AD-9 (PURGADOR)', 'METAL', 'U', 1.000),
('PROD006', 'LT2025006', 'FILTRO SECADOR AD9', 'METAL', 'U', 1.000),
('PROD007', 'LT2025007', 'SERVICIO DE TRANSPORTE', 'SERVICIO', 'NIU', 1000.000),
('PROD008', 'LT2025008', 'BARRA DE ACERO CORRUGADO 1/2"', 'ACERO', 'NIU', 35.500),
('PROD009', 'LT2025009', 'CERAMICA PISO 45X45 CM', 'CERAMICA', 'M2', 12.800),
('PROD010', 'LT2025010', 'CONCENTRADO DE COBRE', 'MINERAL', 'TNE', 1000.000);

INSERT INTO guia_transportista 
(
numero_guia_transportista, fecha_emision, hora_emision, observaciones,
fecha_inicio_traslado, numero_registro_mtc, peso_bruto_total, unidad_medida_peso_bruto,
indicador_pagador_flete, indicador_transporte_subcontratado, indicador_transbordo_programado,
indicador_retorno_vehiculo_vacio, indicador_retorno_envases_vacios,
ruc_subcontratado, ruc_pagador_flete, ruc_transportista, ruc_remitente, ruc_destinatario
) VALUES
('V001-00002246', '2025-10-23', '15:55:00', 'SEGUN GRT EG03-6265', '2025-10-23', '0402965-CNG', 33920.000, 'TNE', 1, 1, 0, 0, 0, '20455870969', '20455870969', '20497947384', '20603171196', '20603171196'),
('EG03-00001374', '2025-10-23', '07:17:00', NULL, '2025-10-23', '0402965CNG', 33546.000, 'TNE', 0, 0, 0, 0, 0, NULL, '20402885549', '20497947384', '20402885549', '20402885549'),
('EG03-00001370', '2025-10-21', '18:42:00', NULL, '2025-10-21', '0402965CNG', 35000.000, 'KGM', 1, 1, 0, 0, 0, '20455870969', '20455870969', '20497947384', '20562926322', '20562926322'),
('EG03-00001366', '2025-10-20', '21:57:00', NULL, '2025-10-20', '0402965CNG', 731.984, 'KGM', 1, 1, 0, 0, 0, '20455870969', '20455870969', '20497947384', '20307146798', '20112273922'),
('EG03-00001363', '2025-10-19', '21:10:00', 'SEGUN GRT EG03-6265', '2025-10-20', '0402965CNG', 34160.000, 'TNE', 1, 1, 0, 0, 0, '20455870969', '20455870969', '20497947384', '20538428524', '20538428524'),
('EG03-00001375', '2025-10-24', '08:30:00', NULL, '2025-10-24', '0402965CNG', 28500.000, 'KGM', 0, 0, 0, 0, 0, NULL, '20402885549', '20497947384', '20402885549', '20402885549'),
('EG03-00001376', '2025-10-24', '10:15:00', NULL, '2025-10-24', '0402965CNG', 15200.000, 'KGM', 1, 1, 0, 0, 0, '20455870969', '20455870969', '20497947384', '20307146798', '20112273922');

INSERT INTO guia_remitente 
(
numero_guia_remitente, numero_guia_transportista, ruc_transportista, ruc_destinatario,
ruc_remitente, cod_local_llegada, cod_local_partida, fecha_entrega_bienes,
modalidad_traslado, hora_emision, fecha_emision, motivo_traslado, observaciones,
peso_total_traslado, dni_conductor, placa_tracto
) VALUES
('T001-00000199', NULL, '20497947384', '20602763103', '20609911876', 'LL001', 'LP001', '2025-09-29', 'PUBLICO', '19:26:00', '2025-09-29', 'VENTA', 'F001-329', 388.000, '42567890', 'V9B123'),
('T001-00000249', NULL, '20497947384', '20600813804', '20610463585', 'LL002', 'LP002', '2025-09-29', 'PUBLICO', '18:50:00', '2025-09-29', 'VENTA', 'F001-317', 228.000, '43123456', 'VCT885'),
('T672-00003545', NULL, '20611606533', '20497947384', '20509709573', 'LL003', 'LP003', '2025-09-29', 'PUBLICO', '15:05:00', '2025-09-25', 'VENTA', 'OV. 171138', 936.000, '29876543', 'V6H456'),
('EG07-00001164', NULL, '20558165902', '20497947384', '20609392968', 'LL004', 'LP004', '2025-10-06', 'PUBLICO', '16:43:00', '2025-10-06', 'VENTA', NULL, 92.000, '31234567', 'V8K789'),
('EG07-00001225', NULL, '20558165902', '20497947384', '20609392968', 'LL004', 'LP004', '2025-10-20', 'PUBLICO', '09:19:00', '2025-10-20', 'VENTA', NULL, 300.000, '31234567', 'V8K789'),
('T003-00017021', NULL, NULL, '20497947384', '20556651508', 'LL005', 'LP005', '2025-10-24', 'PRIVADO', '09:40:00', '2025-10-24', 'VENTA', NULL, 2.000, '44140802', '1225YA'),
('EG07-00001637', 'V001-00002246', '20497947384', '20603171196', '20603171196', 'LL006', 'LP006', '2025-10-23', 'PUBLICO', '14:00:00', '2025-10-23', 'TRASLADO ENTRE ESTABLECIMIENTOS', NULL, 33920.000, '01491281', 'VCT772'),
('T001-71377', 'EG03-00001374', '20497947384', '20402885549', '20402885549', 'LL007', 'LP007', '2025-10-23', 'PUBLICO', '06:30:00', '2025-10-23', 'TRASLADO ENTRE ESTABLECIMIENTOS', NULL, 33546.000, '41013523', 'V8B794'),
('T111-2391', 'EG03-00001370', '20497947384', '20562926322', '20562926322', 'LL008', 'LP008', '2025-10-21', 'PUBLICO', '17:00:00', '2025-10-21', 'VENTA', NULL, 35000.000, '41741101', 'V7L790'),
('T001-228617', 'EG03-00001366', '20497947384', '20112273922', '20307146798', 'LL009', 'LP009', '2025-10-20', 'PUBLICO', '20:30:00', '2025-10-20', 'VENTA', NULL, 731.984, '40301032', 'V7L805'),
('TC01-85923', 'EG03-00001363', '20497947384', '20538428524', '20538428524', 'LL010', 'LP010', '2025-10-20', 'PUBLICO', '19:00:00', '2025-10-19', 'TRASLADO ENTRE ESTABLECIMIENTOS', NULL, 34160.000, '30674107', 'VCS902'),
('T001-71378', 'EG03-00001375', '20497947384', '20402885549', '20402885549', 'LL007', 'LP007', '2025-10-24', 'PUBLICO', '08:00:00', '2025-10-24', 'TRASLADO ENTRE ESTABLECIMIENTOS', NULL, 28500.000, '41013523', 'V8B794'),
('T001-228618', 'EG03-00001376', '20497947384', '20112273922', '20307146798', 'LL009', 'LP009', '2025-10-24', 'PUBLICO', '09:45:00', '2025-10-24', 'VENTA', NULL, 15200.000, '40301032', 'V7L805');


INSERT INTO semirremolque (placa_semirremolque, numero_guia_remitente, certificado_inscripcion_semiremolque) VALUES
('VGG991', 'EG07-00001637', 'SVGG99120241'),
('V9G998', 'T001-71377', 'SV9G99820242'),
('VGJ976', 'T111-2391', 'SVGJ97620243'),
('VGK988', 'T001-228617', 'SVGK98820244'),
('VGG983', 'TC01-85923', 'SVGG98320245'),
('V9H123', 'T001-00000199', 'SV9H12320246'),
('VGM456', 'T001-00000249', 'SVGM45620247'),
('VGN789', 'T672-00003545', 'SVGN78920248'),
('VGP321', 'EG07-00001164', 'SVGP32120249'),
('V9G999', 'T001-71378', 'SV9G99920250'),
('VGK989', 'T001-228618', 'SVGK98920251');

INSERT INTO info_transporte (numero_guia_transportista, dni_conductor, placa_tracto, placa_semirremolque) VALUES
('V001-00002246', '01491281', 'VCT772', 'VGG991'),
('EG03-00001374', '41013523', 'V8B794', 'V9G998'),
('EG03-00001370', '41741101', 'V7L790', 'VGJ976'),
('EG03-00001366', '40301032', 'V7L805', 'VGK988'),
('EG03-00001363', '30674107', 'VCS902', 'VGG983'),
('EG03-00001375', '41013523', 'V8B794', 'V9G999'),
('EG03-00001376', '40301032', 'V7L805', 'VGK989');


INSERT INTO detalle_guia_remitente (numero_guia_remitente, numero_item, codigo_producto, peso_tara, peso_neto, peso_bruto) VALUES
('T001-00000199', 1, 'PROD001', 10.000, 67.600, 77.600),
('T001-00000199', 2, 'PROD001', 10.000, 67.600, 77.600),
('T001-00000199', 3, 'PROD001', 10.000, 67.600, 77.600),
('T001-00000199', 4, 'PROD001', 10.000, 67.600, 77.600),
('T001-00000199', 5, 'PROD001', 10.000, 67.600, 77.600),
('T001-00000249', 1, 'PROD002', 0.000, 228.000, 228.000),
('T672-00003545', 1, 'PROD003', 50.000, 850.000, 900.000),
('T672-00003545', 2, 'PROD003', 2.000, 16.000, 18.000),
('T672-00003545', 3, 'PROD003', 2.000, 16.000, 18.000),
('EG07-00001164', 1, 'PROD004', 0.000, 92.000, 92.000),
('EG07-00001225', 1, 'PROD004', 0.000, 300.000, 300.000),
('T003-00017021', 1, 'PROD005', 0.000, 1.000, 1.000),
('T003-00017021', 2, 'PROD006', 0.000, 1.000, 1.000),
('EG07-00001637', 1, 'PROD007', 0.000, 33920.000, 33920.000),
('T001-71377', 1, 'PROD008', 546.000, 33000.000, 33546.000),
('T111-2391', 1, 'PROD004', 0.000, 35000.000, 35000.000),
('T001-228617', 1, 'PROD009', 31.984, 700.000, 731.984),
('TC01-85923', 1, 'PROD010', 160.000, 34000.000, 34160.000),
('T001-71378', 1, 'PROD008', 500.000, 28000.000, 28500.000),
('T001-228618', 1, 'PROD009', 200.000, 15000.000, 15200.000);


-- ============================================================================
-- CRUDs - SISTEMA GUÍA TRANSPORTISTA
-- ============================================================================


-- MAESTRO: EMPRESA
DELIMITER $$
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

-- MAESTRO: CONDUCTOR
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

-- MAESTRO: TRACTO
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

-- MAESTRO: SEMIRREMOLQUE
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


-- MAESTRO: PRODUCTO
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

-- GUÍA REMITENTE: GUARDAR BORRADOR
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


-- DETALLE GUÍA REMITENTE: INSERT
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


-- DETALLE GUÍA REMITENTE: UPDATE
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


-- DETALLE GUÍA REMITENTE: SOFT DELETE
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


-- GUÍA REMITENTE: FINALIZAR
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


-- INFO TRANSPORTE: INSERT
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


-- GUÍA TRANSPORTISTA: CREAR DESDE REMITENTES (TRANSACCIONAL)
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
-- TRIGGERS DE AUDITORÍA - SISTEMA GUÍA TRANSPORTISTA
DELIMITER $$

-- TRIGGERS: EMPRESA
DROP TRIGGER IF EXISTS trg_empresa_after_insert$$
CREATE TRIGGER trg_empresa_after_insert
AFTER INSERT ON empresa
FOR EACH ROW
BEGIN
-- Solo registrar si no fue por SP; esto debido a que los SP ya auditan
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


-- TRIGGERS: CONDUCTOR
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


-- TRIGGERS: TRACTO
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


-- TRIGGERS: PRODUCTO
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


-- TRIGGERS: GUIA_REMITENTE
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


-- TRIGGERS: GUIA_TRANSPORTISTA
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


-- TRIGGERS: DETALLE_GUIA_REMITENTE
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


-- TRIGGERS: INFO_TRANSPORTE
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


-- TRIGGERS: SEMIRREMOLQUE
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
-- PROCEDIMIENTOS ALMACENADOS: 10 CONSULTAS LOGÍSTICAS
-- ============================================================================

DELIMITER $$
-- REPORTE 1: Búsqueda masiva de GT por rango de fechas
-- Índice utilizado: idx_gt_fecha_emision
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


-- REPORTE 2: Búsqueda individual de GT por número
-- Índice utilizado: PRIMARY KEY (numero_guia_transportista)
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



-- REPORTE 3: GR por rango de fechas y transportista
-- Índices utilizados: idx_gr_fecha_emision, idx_gr_RUC_transportista
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



-- REPORTE 4: Búsqueda por rango de horas
-- Índice utilizado: idx_gt_fecha_emision
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



-- REPORTE 5: Transporte subcontratado
-- Índice utilizado: idx_gt_RUC_subcontratado
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



-- REPORTE 6: Detalle completo de una GR con productos
-- Índices utilizados: idx_det_numero_guia, idx_det_codigo_producto
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



-- REPORTE 7: Análisis de conductores y frecuencia de viajes
-- Índices utilizados: idx_gr_dni_conductor, idx_conductor_nombre
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



-- REPORTE 8: Trazabilidad completa de transporte
-- Índices utilizados: idx_gr_numero_gt, idx_info_numero_guia
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



-- REPORTE 9: Productos más transportados
-- Índices utilizados: idx_det_codigo_producto, ft_producto_descripcion
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



-- REPORTE 10: Resumen de operaciones por empresa
-- Índices utilizados: idx_gt_RUC_transportista, idx_gt_fecha_emision
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
