-- ══════════════════════════════════════════════════════════════
-- SISTEMA DE REMUNERACIONES - CLINICA ACONCAGUA
-- SCRIPT DML (Data Manipulation Language)
-- Contiene SOLO los datos: parametros legales, configuracion
-- y datos de ejemplo (INSERT / UPDATE).
-- REQUISITO: ejecutar antes 01_DDL_estructura.sql
-- ══════════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════
-- DATOS SEMILLA: parametros legales y conceptos base
-- ══════════════════════════════════════════════════════════════
INSERT INTO config_tasas_afp (nombre_afp, tasa_total_porcentaje) VALUES
('AFP Uno',       10.46),
('AFP Modelo',    10.58),
('AFP PlanVital', 11.16),
('AFP Habitat',   11.27),
('AFP Capital',   11.44),
('AFP Cuprum',    11.44),
('AFP ProVida',   11.45);

INSERT INTO config_tasas_salud (institucion, tasa_porcentaje) VALUES
('Fonasa', 7.00),
('Isapre', 7.00);

INSERT INTO config_aportes_empleador (concepto, tasa_porcentaje) VALUES
('Seguro_Cesantia_Empresa', 2.40),
('SIS',                     1.88),
('Expectativa_Vida',        0.90),
('Aporte_Capitalizacion',   0.10);

INSERT INTO tabla_tramos_impuesto (tramo_numero, desde_utm, hasta_utm, factor, rebaja_utm) VALUES
(1,   0.00,  13.50, 0.000,  0.00),
(2,  13.50,  30.00, 0.040,  0.54),
(3,  30.00,  50.00, 0.080,  1.74),
(4,  50.00,  70.00, 0.135,  4.49),
(5,  70.00,  90.00, 0.230, 11.14),
(6,  90.00, 120.00, 0.304, 17.80),
(7, 120.00, 310.00, 0.350, 23.32),
(8, 310.00,   NULL, 0.400, 38.82);

INSERT INTO concepto_remuneracion (nombre, tipo, clasificacion, descripcion, activo, es_base) VALUES
('Sueldo base',          'Fijo',     'Imponible',    'Remuneracion base mensual pactada en el contrato de trabajo.', TRUE, TRUE),
('Horas extras',         'Variable', 'Imponible',    'Recargo del 50% sobre la hora ordinaria por horas trabajadas fuera de la jornada (Art. 32).', TRUE, TRUE),
('AFP',                  'Fijo',     'No imponible', 'Cotizacion previsional obligatoria descontada segun la AFP del trabajador.', TRUE, TRUE),
('Institucion de salud', 'Fijo',     'No imponible', 'Cotizacion de salud (Fonasa o Isapre) descontada mensualmente.', TRUE, TRUE);

INSERT INTO config_gratificacion (modalidad, porcentaje_mensual, limite_imm_anual, porcentaje_anual) VALUES
('Proporcional', 25.00, 4.75, 30.00);

INSERT INTO config_topes_no_imponibles (concepto, monto_exento_diario) VALUES
('Movilizacion', 60000),
('Colacion',     60000);

INSERT INTO feriado (fecha, descripcion) VALUES
('2025-01-01','Año Nuevo'),('2025-04-18','Viernes Santo'),
('2025-04-19','Sabado Santo'),('2025-05-01','Dia del Trabajo'),
('2025-05-21','Glorias Navales'),('2025-06-20','Dia Pueblos Indigenas'),
('2025-06-29','San Pedro y San Pablo'),('2025-07-16','Virgen del Carmen'),
('2025-08-15','Asuncion de la Virgen'),('2025-09-18','Independencia Nacional'),
('2025-09-19','Glorias del Ejercito'),('2025-10-12','Encuentro Dos Mundos'),
('2025-10-31','Dia Iglesias Evangelicas'),('2025-11-01','Dia Todos los Santos'),
('2025-11-16','Elecciones'),('2025-12-08','Inmaculada Concepcion'),
('2025-12-25','Navidad'),('2026-01-01','Año Nuevo'),
('2026-04-03','Viernes Santo'),('2026-04-04','Sabado Santo'),
('2026-05-01','Dia del Trabajo'),('2026-05-21','Glorias Navales'),
('2026-06-22','Dia Pueblos Indigenas'),('2026-06-29','San Pedro y San Pablo'),
('2026-07-16','Virgen del Carmen'),('2026-08-15','Asuncion de la Virgen'),
('2026-09-18','Independencia Nacional'),('2026-09-19','Glorias del Ejercito'),
('2026-10-12','Encuentro Dos Mundos'),('2026-10-31','Dia Iglesias Evangelicas'),
('2026-11-01','Dia Todos los Santos'),('2026-12-08','Inmaculada Concepcion'),
('2026-12-25','Navidad');


-- ══════════════════════════════════════════════════════════════
-- DATOS DE PRUEBA: departamentos, personas, cuentas, trabajadores
-- (contrasena para todas: Aconcagua2024!)
-- ══════════════════════════════════════════════════════════════
INSERT INTO departamento (nombre, codigo, descripcion) VALUES
('Informatica',    'TI',  'Departamento de Informatica'),
('Administracion', 'ADM', 'Departamento de Administracion');

INSERT INTO persona (rut, primer_nombre, segundo_nombre, apellido_paterno, apellido_materno, correo_institucional, cargo, fecha_ingreso, activo) VALUES
('14.111.222-3', 'Carmen',    NULL,       'Rodriguez', 'Vega',       'admin.rrhh@accaconcagua.cl',        'Jefa de RRHH',           '2015-03-01', TRUE),
('15.333.444-5', 'Roberto',   NULL,       'Fuentes',   'Mora',       'jefe.personal@accaconcagua.cl',     'Jefe de Personal',       '2018-06-01', TRUE),
('18.679.609-8', 'Edgar',     NULL,       'Guerra',    'Estay',      'edgar.guerra@accaconcagua.cl',      'Jefe de Informatica',    '2012-04-04', TRUE),
('13.363.607-2', 'Carolina',  NULL,       'Barrera',   'Calderon',   'carolina.barrera@accaconcagua.cl',  'Tecnico de Informatica', '2011-06-01', TRUE),
('9.421.107-7',  'Bernardita','Angelica', 'Alonso',    'Pesenti',    'bernardita.alonso@accaconcagua.cl', 'Tecnico de Informatica', '2023-03-20', TRUE),
('11.858.546-1', 'Paulina',   NULL,       'Apariz',    'Toledo',     'paulina.apariz@accaconcagua.cl',    'Tecnico de Informatica', '2017-05-01', TRUE),
('11.517.545-9', 'Roxana',    NULL,       'Arancibia', 'Montenegro', 'roxana.arancibia@accaconcagua.cl',  'Tecnico de Informatica', '2020-09-01', TRUE),
('20.408.227-8', 'Valentina', NULL,       'Araya',     'Montenegro', 'valentina.araya@accaconcagua.cl',   'Tecnico de Informatica', '2018-11-06', TRUE),
('13.184.896-K', 'Natacha',   NULL,       'Bergel',    'Santibanes', 'natacha.bergel@accaconcagua.cl',    'Tecnico de Informatica', '2021-11-16', TRUE),
('13.054.116-K', 'Lorena',    'Cecilia',  'Bravo',     'Munoz',      'lorena.bravo@accaconcagua.cl',      'Tecnico de Informatica', '2024-10-08', TRUE),
('13.827.661-9', 'Carolina',  'Priscila', 'Carcamo',   'Cornejo',    'carolina.carcamo@accaconcagua.cl',  'Tecnico de Informatica', '2019-03-25', TRUE),
('12.579.214-6', 'Margarita', NULL,       'Catalan',   'Toledo',     'margarita.catalan@accaconcagua.cl', 'Tecnico de Informatica', '2014-04-01', TRUE),
('12.817.448-6', 'Patricia',  NULL,       'Cataldo',   'Gamboa',     'patricia.cataldo@accaconcagua.cl',  'Tecnico de Informatica', '2022-04-05', TRUE),
('18.397.477-7', 'Maria',     'Jose',     'Gallardo',  'Aracena',    'maria.gallardo@accaconcagua.cl',    'Tecnico de Informatica', '2021-09-16', TRUE),
('20.224.612-5', 'Benjamin',  NULL,       'Gonzalez',  'Pacheco',    'benjamin.gonzalez@accaconcagua.cl', 'Tecnico de Informatica', '2021-02-15', TRUE),
('9.164.056-2',  'Fernando',  'Francisco','Gonzalez',  'Calderon',   'fernando.gonzalez@accaconcagua.cl', 'Tecnico de Informatica', '2022-10-04', TRUE),
('19.888.083-3', 'Nicolas',   'Ignacio',  'Guerra',    'Estay',      'nicolas.guerra@accaconcagua.cl',    'Tecnico de Informatica', '2022-02-21', TRUE);

INSERT INTO cuenta_acceso (correo_institucional, contrasena, rol, persona_id, cuenta_verificada) VALUES
('admin.rrhh@accaconcagua.cl',        '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'admin',   (SELECT persona_id FROM persona WHERE rut='14.111.222-3'), TRUE),
('jefe.personal@accaconcagua.cl',     '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'admin',   (SELECT persona_id FROM persona WHERE rut='15.333.444-5'), TRUE),
('edgar.guerra@accaconcagua.cl',      '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'jefe',    (SELECT persona_id FROM persona WHERE rut='18.679.609-8'), TRUE),
('carolina.barrera@accaconcagua.cl',  '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'jefe',    (SELECT persona_id FROM persona WHERE rut='13.363.607-2'), TRUE),
('bernardita.alonso@accaconcagua.cl', '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='9.421.107-7'),  TRUE),
('paulina.apariz@accaconcagua.cl',    '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='11.858.546-1'), TRUE),
('roxana.arancibia@accaconcagua.cl',  '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='11.517.545-9'), TRUE),
('valentina.araya@accaconcagua.cl',   '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='20.408.227-8'), TRUE),
('natacha.bergel@accaconcagua.cl',    '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='13.184.896-K'), TRUE),
('lorena.bravo@accaconcagua.cl',      '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='13.054.116-K'), TRUE),
('carolina.carcamo@accaconcagua.cl',  '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='13.827.661-9'), TRUE),
('margarita.catalan@accaconcagua.cl', '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='12.579.214-6'), FALSE),
('patricia.cataldo@accaconcagua.cl',  '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='12.817.448-6'), TRUE),
('maria.gallardo@accaconcagua.cl',    '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='18.397.477-7'), TRUE),
('benjamin.gonzalez@accaconcagua.cl', '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='20.224.612-5'), TRUE),
('fernando.gonzalez@accaconcagua.cl', '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='9.164.056-2'),  TRUE),
('nicolas.guerra@accaconcagua.cl',    '$2b$12$gHIX4PR3h7ZVPw/qJOBUcum1IRYW1dkatzxB2zTF8r8kvvMUSRmVq', 'usuario', (SELECT persona_id FROM persona WHERE rut='19.888.083-3'), FALSE);

INSERT INTO administrador (persona_id) VALUES
((SELECT persona_id FROM persona WHERE rut='14.111.222-3')),
((SELECT persona_id FROM persona WHERE rut='15.333.444-5'));

INSERT INTO trabajador (persona_id, departamento_id, meses_cotizados_previos) VALUES
((SELECT persona_id FROM persona WHERE rut='18.679.609-8'), (SELECT departamento_id FROM departamento WHERE codigo='TI'),  0),
((SELECT persona_id FROM persona WHERE rut='13.363.607-2'), (SELECT departamento_id FROM departamento WHERE codigo='ADM'), 0),
((SELECT persona_id FROM persona WHERE rut='9.421.107-7'),  (SELECT departamento_id FROM departamento WHERE codigo='TI'),  0),
((SELECT persona_id FROM persona WHERE rut='11.858.546-1'), (SELECT departamento_id FROM departamento WHERE codigo='ADM'), 0),
((SELECT persona_id FROM persona WHERE rut='11.517.545-9'), (SELECT departamento_id FROM departamento WHERE codigo='ADM'), 0),
((SELECT persona_id FROM persona WHERE rut='20.408.227-8'), (SELECT departamento_id FROM departamento WHERE codigo='ADM'), 0),
((SELECT persona_id FROM persona WHERE rut='13.184.896-K'), (SELECT departamento_id FROM departamento WHERE codigo='ADM'), 0),
((SELECT persona_id FROM persona WHERE rut='13.054.116-K'), (SELECT departamento_id FROM departamento WHERE codigo='TI'),  0),
((SELECT persona_id FROM persona WHERE rut='13.827.661-9'), (SELECT departamento_id FROM departamento WHERE codigo='TI'),  0),
((SELECT persona_id FROM persona WHERE rut='12.579.214-6'), (SELECT departamento_id FROM departamento WHERE codigo='TI'),  0),
((SELECT persona_id FROM persona WHERE rut='12.817.448-6'), (SELECT departamento_id FROM departamento WHERE codigo='TI'),  0),
((SELECT persona_id FROM persona WHERE rut='18.397.477-7'), (SELECT departamento_id FROM departamento WHERE codigo='TI'),  0),
((SELECT persona_id FROM persona WHERE rut='20.224.612-5'), (SELECT departamento_id FROM departamento WHERE codigo='TI'),  0),
((SELECT persona_id FROM persona WHERE rut='9.164.056-2'),  (SELECT departamento_id FROM departamento WHERE codigo='TI'),  0),
((SELECT persona_id FROM persona WHERE rut='19.888.083-3'), (SELECT departamento_id FROM departamento WHERE codigo='TI'),  0);

INSERT INTO jefe (persona_id, trabajador_id, departamento_id, area) VALUES
((SELECT persona_id FROM persona WHERE rut='18.679.609-8'),
 (SELECT trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='18.679.609-8'),
 (SELECT departamento_id FROM departamento WHERE codigo='TI'), 'Informatica'),
((SELECT persona_id FROM persona WHERE rut='13.363.607-2'),
 (SELECT trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='13.363.607-2'),
 (SELECT departamento_id FROM departamento WHERE codigo='ADM'), 'Administracion');

INSERT INTO contrato (trabajador_id, tipo_contrato, fecha_ingreso, sueldo_base, jornada_semanal_horas, cargo, tipo_afp, institucion_salud, estado) VALUES
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='18.679.609-8'), 'Indefinido', '2012-04-04', 800000,  44, 'Jefe de Informatica',    'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='13.363.607-2'), 'Indefinido', '2011-06-01', 1100000, 44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='9.421.107-7'),  'Indefinido', '2023-03-20', 1100000, 44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='11.858.546-1'), 'Indefinido', '2017-05-01', 600000,  44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='11.517.545-9'), 'Indefinido', '2020-09-01', 750000,  44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='20.408.227-8'), 'Indefinido', '2018-11-06', 700000,  44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='13.184.896-K'), 'Indefinido', '2021-11-16', 650000,  44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='13.054.116-K'), 'Plazo Fijo', '2024-10-08', 900000,  44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='13.827.661-9'), 'Indefinido', '2019-03-25', 600000,  44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='12.579.214-6'), 'Indefinido', '2014-04-01', 750000,  44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='12.817.448-6'), 'Indefinido', '2022-04-05', 1000000, 44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='18.397.477-7'), 'Indefinido', '2021-09-16', 600000,  44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='20.224.612-5'), 'Indefinido', '2021-02-15', 750000,  44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='9.164.056-2'),  'Indefinido', '2022-10-04', 900000,  44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo'),
((SELECT t.trabajador_id FROM trabajador t JOIN persona p ON p.persona_id=t.persona_id WHERE p.rut='19.888.083-3'), 'Plazo Fijo', '2022-02-21', 950000,  44, 'Tecnico de Informatica', 'AFP Capital', 'Fonasa', 'activo');

INSERT INTO saldo_vacaciones (trabajador_id, dias_disponibles, dias_progresivos)
SELECT
    t.trabajador_id,
    CASE WHEN EXTRACT(YEAR FROM AGE(NOW(), p.fecha_ingreso)) >= 10 THEN 20 ELSE 15 END,
    CASE WHEN EXTRACT(YEAR FROM AGE(NOW(), p.fecha_ingreso)) >= 10 THEN 5  ELSE 0  END
FROM trabajador t
JOIN persona p ON p.persona_id = t.persona_id;

--PARA PROBAR CUENTAS NUEVAS SIN LA NECESIDAD DE LA VERIFICACION SE PUEDE EJECUTAR EL SIGUIENTE COMANDO
UPDATE cuenta_acceso
SET cuenta_verificada = TRUE
WHERE correo_institucional = 'TU_CORREO_AQUI';
