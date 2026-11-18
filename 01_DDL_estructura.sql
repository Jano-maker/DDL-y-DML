-- ══════════════════════════════════════════════════════════════
-- SISTEMA DE REMUNERACIONES - CLINICA ACONCAGUA
-- SCRIPT DDL (Data Definition Language)
-- Contiene SOLO la estructura de la base de datos: tablas,
-- indices, funciones, triggers y vistas. No inserta datos.
-- ORDEN DE EJECUCION: 1) 01_DDL_estructura.sql  2) 02_DML_datos.sql
-- ══════════════════════════════════════════════════════════════

 
-- ────────────────────────────────────────────────────────────
-- 1. DEPARTAMENTO
-- ────────────────────────────────────────────────────────────
CREATE TABLE departamento (
    departamento_id SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    codigo          VARCHAR(10) UNIQUE,
    descripcion     TEXT
);
 
-- ────────────────────────────────────────────────────────────
-- 2. PERSONA (superclase)
-- ────────────────────────────────────────────────────────────
CREATE TABLE persona (
    persona_id              SERIAL PRIMARY KEY,
    rut                     VARCHAR(12) NOT NULL UNIQUE CHECK (rut = UPPER(rut)),
    primer_nombre           VARCHAR(30) NOT NULL,
    segundo_nombre          VARCHAR(30),
    apellido_paterno        VARCHAR(30) NOT NULL,
    apellido_materno        VARCHAR(30) NOT NULL,
    correo_institucional    VARCHAR(100) NOT NULL UNIQUE,
    telefono                VARCHAR(20),
    direccion               VARCHAR(255),
    fecha_nacimiento        DATE,
    activo                  BOOLEAN DEFAULT TRUE,
    cargo                   VARCHAR(100),
    fecha_ingreso           DATE,
    tipo_afp                VARCHAR(50),
    institucion_salud       VARCHAR(20)
);
 
-- ────────────────────────────────────────────────────────────
-- 3. CUENTA_ACCESO
-- ────────────────────────────────────────────────────────────
CREATE TABLE cuenta_acceso (
    cuenta_id               SERIAL PRIMARY KEY,
    correo_institucional    VARCHAR(100) NOT NULL UNIQUE,
    contrasena              VARCHAR(255) NOT NULL,
    rol                     VARCHAR(20) NOT NULL CHECK (rol IN ('admin','jefe','usuario')),
    bloqueada               BOOLEAN DEFAULT FALSE,
    intentos_fallidos       INT DEFAULT 0,
    bloqueada_hasta         TIMESTAMP,
    activo                  BOOLEAN DEFAULT TRUE,
    cuenta_verificada       BOOLEAN DEFAULT FALSE,
    persona_id              INT REFERENCES persona(persona_id),
    estado_cuenta           VARCHAR(20) NOT NULL DEFAULT 'activa'
                            CHECK (estado_cuenta IN ('pendiente','activa','rechazada')),
    codigo_vinculacion      VARCHAR(6),
    fecha_solicitud         TIMESTAMP,
    ip_solicitud            VARCHAR(45)
);
CREATE INDEX idx_cuenta_ip_fecha ON cuenta_acceso (ip_solicitud, fecha_solicitud);
CREATE INDEX idx_cuenta_pendiente ON cuenta_acceso (estado_cuenta) WHERE estado_cuenta = 'pendiente';
 
-- ────────────────────────────────────────────────────────────
-- 4. TRABAJADOR
-- ────────────────────────────────────────────────────────────
CREATE TABLE trabajador (
    trabajador_id           SERIAL PRIMARY KEY,
    discapacidad            TEXT,
    meses_cotizados_previos INT DEFAULT 0,
    persona_id              INT NOT NULL UNIQUE REFERENCES persona(persona_id),
    departamento_id         INT REFERENCES departamento(departamento_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 5. ADMINISTRADOR
-- ────────────────────────────────────────────────────────────
CREATE TABLE administrador (
    administrador_id SERIAL PRIMARY KEY,
    persona_id       INT NOT NULL UNIQUE REFERENCES persona(persona_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 6. JEFE
-- ────────────────────────────────────────────────────────────
CREATE TABLE jefe (
    jefe_id         SERIAL PRIMARY KEY,
    area            VARCHAR(100),
    trabajador_id   INT NOT NULL UNIQUE REFERENCES trabajador(trabajador_id),
    persona_id      INT NOT NULL REFERENCES persona(persona_id),
    departamento_id INT REFERENCES departamento(departamento_id)
);
 
-- ────────────────────────────────────────────────────────────
-- SUPERVISION
-- ────────────────────────────────────────────────────────────
CREATE TABLE supervision (
    administrador_id INT NOT NULL REFERENCES administrador(administrador_id),
    trabajador_id    INT NOT NULL REFERENCES trabajador(trabajador_id),
    area_supervision VARCHAR(100),
    tipo_supervision VARCHAR(50),
    PRIMARY KEY (administrador_id, trabajador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 7. CONTRATO
-- ────────────────────────────────────────────────────────────
CREATE TABLE contrato (
    contrato_id            SERIAL PRIMARY KEY,
    tipo_contrato          VARCHAR(30) NOT NULL,
    fecha_ingreso          DATE NOT NULL,
    fecha_vencimiento      DATE,
    tipo_afp               VARCHAR(50),
    institucion_salud      VARCHAR(20),
    cargo                  VARCHAR(100),
    sueldo_base            NUMERIC(12,2),
    jornada_semanal_horas  NUMERIC(5,2),
    turno                  VARCHAR(30) NOT NULL DEFAULT 'Turno Fijo'
                               CHECK (turno IN ('Turno Rotativo 1','Turno Rotativo 2','Turno Rotativo 3','Turno Fijo')),
    renovado               BOOLEAN DEFAULT FALSE,
    estado                 VARCHAR(20) DEFAULT 'activo',
    trabajador_id          INT NOT NULL REFERENCES trabajador(trabajador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- COTIZACIONES_PREVIAS
-- ────────────────────────────────────────────────────────────
CREATE TABLE cotizaciones_previas (
    cotiz_id                        SERIAL PRIMARY KEY,
    meses_cotizados_previos         INT DEFAULT 0,
    meses_cotizados_total           INT DEFAULT 0,
    fecha_presentacion_certificado  DATE,
    ruta_archivo                    VARCHAR(255),
    trabajador_id                   INT NOT NULL REFERENCES trabajador(trabajador_id),
    administrador_id                INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 8. SALDO_VACACIONES
-- ────────────────────────────────────────────────────────────
CREATE TABLE saldo_vacaciones (
    saldo_id                 SERIAL PRIMARY KEY,
    dias_disponibles         INT DEFAULT 15,
    dias_progresivos         INT DEFAULT 0,
    dias_utilizados          INT DEFAULT 0,
    dias_acumulados          NUMERIC(9,4) DEFAULT 0,
    dias_vendidos            INT DEFAULT 0,
    periodo_sin_uso          INT DEFAULT 0,
    ultimo_incremento_anual  DATE,
    ultima_actualizacion     TIMESTAMP DEFAULT NOW(),
    trabajador_id            INT NOT NULL UNIQUE REFERENCES trabajador(trabajador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 9. SOLICITUD_VACACIONES
-- ────────────────────────────────────────────────────────────
CREATE TABLE solicitud_vacaciones (
    solicitud_id        SERIAL PRIMARY KEY,
    fecha_inicio        DATE NOT NULL,
    fecha_fin           DATE NOT NULL,
    dias_habiles        INT NOT NULL,
    estado              VARCHAR(20) DEFAULT 'Pendiente',
    tipo_dias           VARCHAR(20) NOT NULL DEFAULT 'normal' CHECK (tipo_dias IN ('normal', 'progresivo')),
    observacion         TEXT,
    fecha_decision      TIMESTAMP,
    saldo_actualizado   INT,
    comprobante_pdf     BYTEA,
    fecha_solicitud     TIMESTAMP DEFAULT NOW(),
    trabajador_id       INT NOT NULL REFERENCES trabajador(trabajador_id),
    revisado_por        INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 10. FERIADO
-- ────────────────────────────────────────────────────────────
CREATE TABLE feriado (
    feriado_id  SERIAL PRIMARY KEY,
    fecha       DATE NOT NULL UNIQUE,
    descripcion VARCHAR(100) NOT NULL
);
 
-- ────────────────────────────────────────────────────────────
-- ASISTENCIA
-- ────────────────────────────────────────────────────────────
CREATE TABLE asistencia (
    asistencia_id       SERIAL PRIMARY KEY,
    fecha               DATE NOT NULL,
    estado_dia          VARCHAR(30),
    hora_entrada        TIME,
    hora_salida         TIME,
    dias_inasistencia   INT DEFAULT 0,
    periodo             VARCHAR(7),
    semana_corrida      BOOLEAN DEFAULT FALSE,
    trabajador_id       INT NOT NULL REFERENCES trabajador(trabajador_id),
    feriado_id          INT REFERENCES feriado(feriado_id),
    CONSTRAINT asistencia_trabajador_fecha_unique UNIQUE (trabajador_id, fecha)
);
 
CREATE TABLE calculo_atraso (
    calculo_atraso_id   SERIAL PRIMARY KEY,
    minutos_atraso      INT DEFAULT 0,
    asistencia_id       INT NOT NULL UNIQUE REFERENCES asistencia(asistencia_id)
);
 
-- ────────────────────────────────────────────────────────────
-- DOCUMENTO
-- ────────────────────────────────────────────────────────────
CREATE TABLE documento (
    documento_id        SERIAL PRIMARY KEY,
    tipo_documento      VARCHAR(50) NOT NULL,
    periodo             VARCHAR(7),
    fecha_carga         TIMESTAMP DEFAULT NOW(),
    codigo_verificacion VARCHAR(100),
    comprobante_pdf     BYTEA,
    cargado_por         INT REFERENCES administrador(administrador_id),
    trabajador_id       INT NOT NULL REFERENCES trabajador(trabajador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 11. HORAS_EXTRAS
-- ────────────────────────────────────────────────────────────
CREATE TABLE horas_extras (
    horas_id                SERIAL PRIMARY KEY,
    cantidad_horas          NUMERIC(4,1) NOT NULL,
    valor_hora_ordinaria    NUMERIC(10,2) NOT NULL,
    estado                  VARCHAR(20) DEFAULT 'Aprobada',
    periodo                 VARCHAR(7),
    fecha_aprobacion        DATE,
    trabajador_id           INT NOT NULL REFERENCES trabajador(trabajador_id),
    revisado_por            INT REFERENCES administrador(administrador_id),
    UNIQUE (trabajador_id, periodo)
);
 
CREATE TABLE calculo_horas (
    calculo_id  SERIAL PRIMARY KEY,
    monto_clp   NUMERIC(12,2) NOT NULL,
    horas_id    INT NOT NULL UNIQUE REFERENCES horas_extras(horas_id)
);

-- ────────────────────────────────────────────────────────────
-- SOLICITUD_HORAS_EXTRAS (referencia del trabajador)
-- Tabla separada de Horas_Extras a proposito: evita que la solicitud
-- del trabajador y el registro real que hace el administrador en
-- Calculo Liquidacion Total terminen escribiendo sobre la misma fila.
-- El trabajador solicita, el administrador aprueba o rechaza (solo
-- de referencia, no calcula ni suma nada), y queda un PDF de respaldo
-- guardado en Documentos.
-- ────────────────────────────────────────────────────────────
CREATE TABLE solicitud_horas_extras (
    solicitud_id     SERIAL PRIMARY KEY,
    trabajador_id    INT NOT NULL REFERENCES trabajador(trabajador_id),
    periodo          VARCHAR(7) NOT NULL,
    cantidad_horas   NUMERIC(4,1) NOT NULL CHECK (cantidad_horas > 0),
    estado           VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'aprobada', 'rechazada')),
    observacion      TEXT,
    fecha_solicitud  TIMESTAMP DEFAULT NOW(),
    fecha_decision   TIMESTAMP,
    aprobado_por     INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 12. LICENCIA_MEDICA
-- ────────────────────────────────────────────────────────────
CREATE TABLE licencia_medica (
    licencia_id             SERIAL PRIMARY KEY,
    tipo_de_licencia        VARCHAR(50) NOT NULL,
    fecha_inicio            DATE NOT NULL,
    fecha_fin               DATE NOT NULL,
    entidad_emisora         VARCHAR(100),
    descuento_proporcional  NUMERIC(12,2) DEFAULT 0,
    periodo                 VARCHAR(7),
    trabajador_id           INT NOT NULL REFERENCES trabajador(trabajador_id),
    ingresado_por           INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 13. LIQUIDACIONES_PDF
-- ────────────────────────────────────────────────────────────
CREATE TABLE liquidaciones_pdf (
    liquidacion_pdf_id   SERIAL PRIMARY KEY,
    periodo              VARCHAR(6) NOT NULL,
    nombre_archivo       VARCHAR(50) NOT NULL,
    archivo_pdf          BYTEA NOT NULL,
    tamano_bytes         INT NOT NULL,
    codigo_verificacion  VARCHAR(12) UNIQUE,
    disponible           BOOLEAN DEFAULT TRUE,
    fecha_subida         TIMESTAMP DEFAULT NOW(),
    trabajador_id        INT REFERENCES trabajador(trabajador_id),
    subido_por           INT REFERENCES administrador(administrador_id),
    UNIQUE (trabajador_id, periodo)
);
 
-- ────────────────────────────────────────────────────────────
-- 14. CERTIFICADOS_AFP
-- ────────────────────────────────────────────────────────────
CREATE TABLE certificados_afp (
    id              SERIAL PRIMARY KEY,
    nombre_archivo  VARCHAR(100),
    archivo_pdf     BYTEA NOT NULL,
    tamano_bytes    INT,
    fecha_subida    TIMESTAMP DEFAULT NOW(),
    trabajador_id   INT REFERENCES trabajador(trabajador_id),
    subido_por      INT REFERENCES administrador(administrador_id),
    UNIQUE (trabajador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 15. CONFIG_GRATIFICACION
-- ────────────────────────────────────────────────────────────
CREATE TABLE config_gratificacion (
    config_id           SERIAL PRIMARY KEY,
    modalidad           VARCHAR(30) NOT NULL,
    porcentaje_anual    NUMERIC(5,2),
    limite_imm_anual    NUMERIC(12,2),
    porcentaje_mensual  NUMERIC(5,2),
    fecha_modificacion  TIMESTAMP DEFAULT NOW(),
    modificado_por      INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 16. CONFIG_VALOR_IMM
-- ────────────────────────────────────────────────────────────
CREATE TABLE config_valor_imm (
    imm_id          SERIAL PRIMARY KEY,
    valor_clp       NUMERIC(12,2) NOT NULL CHECK (valor_clp > 0),
    mes             INT NOT NULL,
    anio            INT NOT NULL,
    fecha_ingreso   TIMESTAMP DEFAULT NOW(),
    ingresado_por   INT REFERENCES administrador(administrador_id),
    UNIQUE (mes, anio)
);
 
-- ────────────────────────────────────────────────────────────
-- 17. VALOR_UTM
-- ────────────────────────────────────────────────────────────
CREATE TABLE valor_utm (
    utm_id          SERIAL PRIMARY KEY,
    valor_clp       NUMERIC(12,2) NOT NULL,
    mes             INT NOT NULL,
    anio            INT NOT NULL,
    fecha_ingreso   TIMESTAMP DEFAULT NOW(),
    ingresado_por   INT REFERENCES administrador(administrador_id),
    UNIQUE (mes, anio)
);
 
-- ────────────────────────────────────────────────────────────
-- 18. CONFIG_VALOR_UF
-- ────────────────────────────────────────────────────────────
CREATE TABLE config_valor_uf (
    uf_id           SERIAL PRIMARY KEY,
    valor_uf        NUMERIC(12,2) NOT NULL CHECK (valor_uf > 0),
    tope_afp_salud  NUMERIC(12,2) NOT NULL CHECK (tope_afp_salud > 0),
    tope_afc        NUMERIC(12,2) NOT NULL CHECK (tope_afc > 0),
    mes             INT NOT NULL,
    anio            INT NOT NULL,
    fecha_ingreso   TIMESTAMP DEFAULT NOW(),
    ingresado_por   INT REFERENCES administrador(administrador_id),
    UNIQUE (mes, anio)
);
 
-- ────────────────────────────────────────────────────────────
-- 19. CONFIG_TASAS_AFP
-- ────────────────────────────────────────────────────────────
CREATE TABLE config_tasas_afp (
    afp_id                  SERIAL PRIMARY KEY,
    nombre_afp              VARCHAR(50) NOT NULL UNIQUE,
    tasa_total_porcentaje   NUMERIC(5,2) NOT NULL CHECK (tasa_total_porcentaje > 0),
    fecha_modificacion      TIMESTAMP DEFAULT NOW(),
    modificado_por          INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 20. CONFIG_TASAS_SALUD
-- ────────────────────────────────────────────────────────────
CREATE TABLE config_tasas_salud (
    salud_id            SERIAL PRIMARY KEY,
    institucion         VARCHAR(50) NOT NULL UNIQUE,
    tasa_porcentaje     NUMERIC(5,2) NOT NULL CHECK (tasa_porcentaje > 0),
    fecha_modificacion  TIMESTAMP DEFAULT NOW(),
    modificado_por      INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 21. CONFIG_APORTES_EMPLEADOR
-- ────────────────────────────────────────────────────────────
CREATE TABLE config_aportes_empleador (
    aporte_id           SERIAL PRIMARY KEY,
    concepto            VARCHAR(30) NOT NULL UNIQUE,
    tasa_porcentaje     NUMERIC(5,2) NOT NULL CHECK (tasa_porcentaje >= 0),
    fecha_modificacion  TIMESTAMP DEFAULT NOW(),
    modificado_por      INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 22. TABLA_TRAMOS_IMPUESTO
-- ────────────────────────────────────────────────────────────
CREATE TABLE tabla_tramos_impuesto (
    tramo_id            SERIAL PRIMARY KEY,
    tramo_numero        INT NOT NULL UNIQUE,
    desde_utm           NUMERIC(8,2) NOT NULL,
    hasta_utm           NUMERIC(8,2),
    factor              NUMERIC(5,4) NOT NULL,
    rebaja_utm          NUMERIC(8,2) NOT NULL,
    fecha_modificacion  TIMESTAMP DEFAULT NOW(),
    modificado_por      INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 23. CONCEPTO_REMUNERACION
-- ────────────────────────────────────────────────────────────
CREATE TABLE concepto_remuneracion (
    concepto_id         SERIAL PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    tipo                VARCHAR(30) CHECK (tipo IN ('Fijo', 'Variable')),
    clasificacion       VARCHAR(30) CHECK (clasificacion IN ('Imponible', 'No imponible')),
    descripcion         TEXT,
    activo              BOOLEAN DEFAULT TRUE,
    es_base              BOOLEAN DEFAULT FALSE,
    fecha_modificacion  TIMESTAMP DEFAULT NOW(),
    modificado_por      INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 24. LIQUIDACION
-- ────────────────────────────────────────────────────────────
CREATE TABLE liquidacion (
    liquidacion_id              SERIAL PRIMARY KEY,
    mes                         INT NOT NULL,
    anio                        INT NOT NULL,
    periodo                     VARCHAR(7),
    tipo_liquidacion            VARCHAR(20) NOT NULL DEFAULT 'normal' CHECK (tipo_liquidacion IN ('normal', 'complementaria')),
    observacion_complementaria  TEXT,
    liquido_a_pagar             NUMERIC(12,2),
    sueldo_base                 NUMERIC(12,2),
    total_haberes_imponible     NUMERIC(12,2) DEFAULT 0,
    total_haberes_no_imponible  NUMERIC(12,2) DEFAULT 0,
    descuento_afp               NUMERIC(12,2) DEFAULT 0,
    descuento_salud             NUMERIC(12,2) DEFAULT 0,
    descuento_afc_trabajador    NUMERIC(12,2) DEFAULT 0,
    aporte_afc_empleador        NUMERIC(12,2) DEFAULT 0,
    impuesto_unico              NUMERIC(12,2) DEFAULT 0,
    utm_valor_clp               NUMERIC(12,2),
    gratificacion               NUMERIC(12,2) DEFAULT 0,
    horas_extras                NUMERIC(12,2) DEFAULT 0,
    sueldo_proporcional         NUMERIC(12,2),
    dias_trabajados             INT,
    total_descuento             NUMERIC(12,2) DEFAULT 0,
    costo_total_empleador       NUMERIC(12,2),
    estado                      VARCHAR(20) DEFAULT 'borrador',
    fecha_cierre                TIMESTAMP,
    trabajador_id               INT NOT NULL REFERENCES trabajador(trabajador_id),
    contrato_id                 INT REFERENCES contrato(contrato_id),
    cerrada_por                 INT REFERENCES administrador(administrador_id),
    config_id                   INT REFERENCES config_gratificacion(config_id),
    utm_id                      INT REFERENCES valor_utm(utm_id)
);
CREATE UNIQUE INDEX uq_liquidacion_normal_periodo
    ON liquidacion (trabajador_id, periodo)
    WHERE tipo_liquidacion = 'normal';
 
-- ────────────────────────────────────────────────────────────
-- 25. DETALLE_CALCULO_LIQUIDACION
-- ────────────────────────────────────────────────────────────
CREATE TABLE detalle_calculo_liquidacion (
    detalle_id          SERIAL PRIMARY KEY,
    liquidacion_id      INT NOT NULL REFERENCES liquidacion(liquidacion_id),
    concepto            VARCHAR(100) NOT NULL,
    valores_entrada     TEXT NOT NULL,
    formula_regla       TEXT NOT NULL,
    referencia_legal    VARCHAR(100),
    resultado_clp       INT NOT NULL,
    fecha_registro      TIMESTAMP DEFAULT NOW()
);
 
-- ────────────────────────────────────────────────────────────
-- 26. DESCUENTO
-- ────────────────────────────────────────────────────────────
CREATE TABLE descuento (
    descuento_id            SERIAL PRIMARY KEY,
    tipo_descuento          VARCHAR(50) NOT NULL CHECK (tipo_descuento IN ('Inasistencia', 'Retraso', 'Prestamo')),
    monto_clp               NUMERIC(12,2) NOT NULL,
    dias_evento             NUMERIC(5,2),
    saldo_pendiente         NUMERIC(12,2) DEFAULT 0,
    fecha_evento            DATE,
    periodo                 VARCHAR(7),
    subtipo_prestamo        VARCHAR(30) CHECK (subtipo_prestamo IS NULL OR subtipo_prestamo IN ('Interno', 'CajaCompensacion')),
    monto_prestamo_total    NUMERIC(12,2),
    numero_cuota            INT,
    total_cuotas            INT,
    trabajador_id           INT REFERENCES trabajador(trabajador_id),
    liquidacion_id          INT REFERENCES liquidacion(liquidacion_id),
    registrado_por          INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 27. BONO_IMPONIBLE
-- ────────────────────────────────────────────────────────────
CREATE TABLE bono_imponible (
    bono_id         SERIAL PRIMARY KEY,
    trabajador_id   INT NOT NULL REFERENCES trabajador(trabajador_id),
    tipo_bono       VARCHAR(50) NOT NULL CHECK (tipo_bono IN ('Bonificacion', 'Bonificacion de Produccion', 'Bonificacion por Turno', 'Otros')),
    concepto_otros  VARCHAR(100),
    monto_clp       NUMERIC(12,2) NOT NULL CHECK (monto_clp > 0),
    periodo         VARCHAR(7) NOT NULL,
    fecha_registro  TIMESTAMP DEFAULT NOW(),
    registrado_por  INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 28. BONO_EXCEPCIONAL
-- ────────────────────────────────────────────────────────────
CREATE TABLE bono_excepcional (
    bono_id         SERIAL PRIMARY KEY,
    trabajador_id   INT NOT NULL REFERENCES trabajador(trabajador_id),
    concepto        VARCHAR(100) NOT NULL,
    monto_clp       NUMERIC(12,2) NOT NULL CHECK (monto_clp > 0),
    clasificacion   VARCHAR(30) NOT NULL CHECK (clasificacion IN ('Imponible', 'No imponible')),
    periodo         VARCHAR(7) NOT NULL,
    fecha_registro  TIMESTAMP DEFAULT NOW(),
    registrado_por  INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 29. BONO_REGLA
-- ────────────────────────────────────────────────────────────
CREATE TABLE bono_regla (
    bono_id         SERIAL PRIMARY KEY,
    nombre_concepto VARCHAR(100),
    condicion_texto TEXT,
    monto_fijo_clp  NUMERIC(12,2),
    porcentaje_base NUMERIC(5,2),
    clasificacion   VARCHAR(30) CHECK (clasificacion IN ('Imponible', 'No imponible')),
    activo          BOOLEAN DEFAULT TRUE,
    concepto_id     INT REFERENCES concepto_remuneracion(concepto_id),
    CONSTRAINT chk_monto_o_porcentaje CHECK (
        (monto_fijo_clp IS NOT NULL AND monto_fijo_clp > 0 AND porcentaje_base IS NULL) OR
        (porcentaje_base IS NOT NULL AND porcentaje_base >= 0.01 AND porcentaje_base <= 100 AND monto_fijo_clp IS NULL)
    )
);
 
-- ────────────────────────────────────────────────────────────
-- 30. APLICACION_BONO_REGLA
-- ────────────────────────────────────────────────────────────
CREATE TABLE aplicacion_bono_regla (
    aplicacion_id    SERIAL PRIMARY KEY,
    bono_id          INT NOT NULL REFERENCES bono_regla(bono_id),
    trabajador_id    INT NOT NULL REFERENCES trabajador(trabajador_id),
    periodo          VARCHAR(7) NOT NULL,
    cumple_condicion BOOLEAN NOT NULL,
    monto_aplicado   NUMERIC(12,2) NOT NULL DEFAULT 0,
    fecha_registro   TIMESTAMP DEFAULT NOW(),
    registrado_por   INT REFERENCES administrador(administrador_id),
    UNIQUE (bono_id, trabajador_id, periodo)
);
 
-- ────────────────────────────────────────────────────────────
-- 31. CALCULO_PROPORCIONAL
-- ────────────────────────────────────────────────────────────
CREATE TABLE calculo_proporcional (
    calculo_id                SERIAL PRIMARY KEY,
    trabajador_id             INT NOT NULL REFERENCES trabajador(trabajador_id),
    dias_trabajados           INT NOT NULL CHECK (dias_trabajados BETWEEN 1 AND 30),
    sueldo_diario             NUMERIC(12,4) NOT NULL,
    monto_proporcional        NUMERIC(12,2) NOT NULL,
    colacion_proporcional     NUMERIC(10,2),
    locomocion_proporcional   NUMERIC(10,2),
    periodo                   VARCHAR(7) NOT NULL,
    motivo                    VARCHAR(20) NOT NULL CHECK (motivo IN ('Ingreso', 'Egreso')),
    fecha_registro            TIMESTAMP DEFAULT NOW(),
    registrado_por            INT REFERENCES administrador(administrador_id),
    UNIQUE (trabajador_id, periodo)
);
 
CREATE TABLE calculo_monto_proporcional (
    calculo_monto_id    SERIAL PRIMARY KEY,
    monto_proporcional  NUMERIC(12,2) NOT NULL,
    calculo_id          INT NOT NULL UNIQUE REFERENCES calculo_proporcional(calculo_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 32. CONFIG_TOPES_NO_IMPONIBLES
-- ────────────────────────────────────────────────────────────
CREATE TABLE config_topes_no_imponibles (
    config_id           SERIAL PRIMARY KEY,
    concepto            VARCHAR(30) NOT NULL UNIQUE CHECK (concepto IN ('Movilizacion', 'Colacion')),
    monto_exento_diario NUMERIC(10,2) NOT NULL CHECK (monto_exento_diario > 0),
    fecha_modificacion  TIMESTAMP DEFAULT NOW(),
    modificado_por      INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 33. ASIGNACION_NO_IMPONIBLE
-- ────────────────────────────────────────────────────────────
CREATE TABLE asignacion_no_imponible (
    asignacion_id         SERIAL PRIMARY KEY,
    trabajador_id         INT NOT NULL REFERENCES trabajador(trabajador_id),
    concepto              VARCHAR(30) NOT NULL CHECK (concepto IN ('Movilizacion', 'Colacion')),
    monto_total_mensual   NUMERIC(12,2) NOT NULL CHECK (monto_total_mensual > 0),
    dias_periodo          INT NOT NULL CHECK (dias_periodo BETWEEN 1 AND 31),
    monto_exento          NUMERIC(12,2) NOT NULL,
    monto_excedente       NUMERIC(12,2) NOT NULL DEFAULT 0,
    periodo               VARCHAR(7) NOT NULL,
    fecha_registro        TIMESTAMP DEFAULT NOW(),
    registrado_por        INT REFERENCES administrador(administrador_id),
    UNIQUE (trabajador_id, periodo, concepto)
);
 
CREATE TABLE calculo_monto_no_imponible (
    calculo_monto_id  SERIAL PRIMARY KEY,
    monto_exento      NUMERIC(12,2) NOT NULL,
    monto_excedente   NUMERIC(12,2) NOT NULL DEFAULT 0,
    asignacion_id     INT NOT NULL UNIQUE REFERENCES asignacion_no_imponible(asignacion_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 33b. CONFIRMACION_MOVILIZACION_COLACION
-- ────────────────────────────────────────────────────────────
CREATE TABLE confirmacion_movilizacion_colacion (
    confirmacion_id      SERIAL PRIMARY KEY,
    periodo              VARCHAR(7) UNIQUE NOT NULL,
    monto_movilizacion   NUMERIC(10,2) NOT NULL,
    monto_colacion       NUMERIC(10,2) NOT NULL,
    administrador_id     INT REFERENCES administrador(administrador_id),
    fecha_confirmacion   TIMESTAMP DEFAULT NOW()
);
 
-- ────────────────────────────────────────────────────────────
-- 34. ANTICIPO_SUELDO
-- ────────────────────────────────────────────────────────────
-- tipo_anticipo separa 2 cupos independientes: el Ordinario (que
-- se registra en el wizard de Liquidacion Total y SI descuenta del
-- sueldo) y el Excepcional (que pide el trabajador; queda solo como
-- evidencia/referencia y NO descuenta nada por si mismo). El indice
-- unico de "maximo 1 activo por periodo" es POR TIPO: un trabajador
-- puede tener, el mismo mes, un Ordinario y un Excepcional a la vez.
CREATE TABLE anticipo_sueldo (
    anticipo_id         SERIAL PRIMARY KEY,
    monto_clp           NUMERIC(12,2) NOT NULL,
    periodo             VARCHAR(7),
    folio_autorizacion  VARCHAR(50),
    estado              VARCHAR(20) DEFAULT 'pendiente',
    tipo_anticipo        VARCHAR(20) NOT NULL CHECK (tipo_anticipo IN ('ordinario', 'excepcional')),
    trabajador_id       INT NOT NULL REFERENCES trabajador(trabajador_id),
    liquidacion_id      INT REFERENCES liquidacion(liquidacion_id),
    aprobado_por        INT REFERENCES administrador(administrador_id)
);
CREATE UNIQUE INDEX uq_anticipo_activo_periodo
    ON anticipo_sueldo (trabajador_id, periodo, tipo_anticipo)
    WHERE estado IN ('pendiente', 'aprobado');
 
-- ────────────────────────────────────────────────────────────
-- 35. COMPENSACION_PROGRESIVA
-- ────────────────────────────────────────────────────────────
CREATE TABLE compensacion_progresiva (
    compensacion_id  SERIAL PRIMARY KEY,
    trabajador_id    INT NOT NULL REFERENCES trabajador(trabajador_id),
    dias_compensados INT NOT NULL CHECK (dias_compensados >= 1),
    monto_clp        NUMERIC(12,2) NOT NULL CHECK (monto_clp > 0),
    estado           VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'aprobado', 'rechazado')),
    fecha_solicitud  TIMESTAMP DEFAULT NOW(),
    fecha_decision   TIMESTAMP,
    observacion      TEXT,
    aprobado_por     INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 36. LIQUIDACION_HONORARIO
-- ────────────────────────────────────────────────────────────
CREATE TABLE liquidacion_honorario (
    liquidacion_honorario_id  SERIAL PRIMARY KEY,
    trabajador_id             INT NOT NULL REFERENCES trabajador(trabajador_id),
    periodo                   VARCHAR(7) NOT NULL,
    numero_boleta             VARCHAR(30),
    fecha_emision             DATE,
    periodo_prestacion        VARCHAR(100),
    descripcion_trabajo       VARCHAR(200) NOT NULL,
    honorario_bruto           NUMERIC(12,2) NOT NULL CHECK (honorario_bruto > 0),
    tasa_retencion_aplicada   NUMERIC(5,2) NOT NULL,
    fecha_registro            TIMESTAMP DEFAULT NOW(),
    registrado_por            INT REFERENCES administrador(administrador_id)
);
 
CREATE TABLE calculo_monto_honorario (
    calculo_monto_id          SERIAL PRIMARY KEY,
    monto_retencion           NUMERIC(12,2) NOT NULL,
    honorario_liquido         NUMERIC(12,2) NOT NULL,
    liquidacion_honorario_id  INT NOT NULL REFERENCES liquidacion_honorario(liquidacion_honorario_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 37. CONFIG_RETENCION_HONORARIO
-- ────────────────────────────────────────────────────────────
CREATE TABLE config_retencion_honorario (
    retencion_id    SERIAL PRIMARY KEY,
    tasa_retencion  NUMERIC(5,2) NOT NULL CHECK (tasa_retencion > 0),
    anio            INT NOT NULL UNIQUE,
    fecha_ingreso   TIMESTAMP DEFAULT NOW(),
    ingresado_por   INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 38. FINIQUITO
-- ────────────────────────────────────────────────────────────
CREATE TABLE finiquito (
    finiquito_id                    SERIAL PRIMARY KEY,
    fecha_termino                   DATE NOT NULL,
    causal_desvinculacion           VARCHAR(100),
    vacaciones_proporcionales_clp   NUMERIC(12,2) DEFAULT 0,
    vacaciones_progresivas_clp      NUMERIC(12,2) DEFAULT 0,
    indemnizacion                   NUMERIC(12,2) DEFAULT 0,
    anios_de_servicio               INT DEFAULT 0,
    total_finiquito                 NUMERIC(12,2) DEFAULT 0,
    ruta_pdf                        VARCHAR(255),
    trabajador_id                   INT NOT NULL REFERENCES trabajador(trabajador_id),
    contrato_id                     INT REFERENCES contrato(contrato_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 39. NOTIFICACION
-- ────────────────────────────────────────────────────────────
CREATE TABLE notificacion (
    notificacion_id SERIAL PRIMARY KEY,
    tipo            VARCHAR(50) NOT NULL,
    mensaje         TEXT,
    fecha_envio     TIMESTAMP DEFAULT NOW(),
    urgente         BOOLEAN DEFAULT FALSE,
    canal           VARCHAR(30),
    dias_restantes  INT,
    trabajador_id   INT REFERENCES trabajador(trabajador_id),
    solicitud_id    INT REFERENCES solicitud_vacaciones(solicitud_id),
    contrato_id     INT REFERENCES contrato(contrato_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 40. SOLICITUD_DATOS_PERSONALES
-- ────────────────────────────────────────────────────────────
CREATE TABLE solicitud_datos_personales (
    solicitud_datos_id  SERIAL PRIMARY KEY,
    persona_id          INT NOT NULL REFERENCES persona(persona_id),
    tipo_solicitud      VARCHAR(20) NOT NULL CHECK (tipo_solicitud IN ('Correccion', 'Eliminacion')),
    campo_afectado      VARCHAR(50),
    detalle             TEXT NOT NULL,
    estado              VARCHAR(20) NOT NULL DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Aprobada', 'Rechazada')),
    respuesta_admin     TEXT,
    fecha_solicitud     TIMESTAMP DEFAULT NOW(),
    fecha_respuesta     TIMESTAMP,
    resuelta_por        INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 41. AUDITORIA_BONO_DESCUENTO
-- ────────────────────────────────────────────────────────────
CREATE TABLE auditoria_bono_descuento (
    auditoria_id                   SERIAL PRIMARY KEY,
    administrador_id               INT NOT NULL REFERENCES administrador(administrador_id),
    nombre_administrador_historico VARCHAR(120) NOT NULL,
    rut_administrador_historico    VARCHAR(12) NOT NULL,
    fecha_hora                     TIMESTAMP DEFAULT NOW(),
    trabajador_id                  INT NOT NULL REFERENCES trabajador(trabajador_id),
    rut_trabajador_historico       VARCHAR(12) NOT NULL,
    tipo_ajuste                    VARCHAR(20) NOT NULL CHECK (tipo_ajuste IN ('Bono', 'Descuento')),
    concepto                       VARCHAR(100) NOT NULL,
    monto_clp                      INT NOT NULL
);
 
-- ────────────────────────────────────────────────────────────
-- 42. LOG_AUDITORIA (inalterable via trigger, ver mas abajo)
-- ────────────────────────────────────────────────────────────
-- nombre_completo/rut_administrador: copia en texto del administrador
-- que hizo el cambio, tal como estaba en ese momento (igual criterio
-- que Auditoria_Bono_Descuento). administrador_id es ademas el vinculo
-- real con Administrador. No existe trabajador_id: el trabajador
-- afectado queda solo como copia en nombre_trabajador_afectado.
CREATE TABLE log_auditoria (
    log_id                      SERIAL PRIMARY KEY,
    tabla_afectada              VARCHAR(50),
    registro_identificador      VARCHAR(50),
    tipo_de_operacion           VARCHAR(20),
    campo_modificado            VARCHAR(100),
    modulo                      VARCHAR(50),
    nombre_completo             VARCHAR(120),
    informacion_personal        TEXT,
    fecha_hora                  TIMESTAMP DEFAULT NOW(),
    valor_anterior               TEXT,
    valor_nuevo                 TEXT,
    rut_administrador           VARCHAR(12),
    nombre_trabajador_afectado  VARCHAR(120),
    administrador_id            INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 43. LOG_ERRORES_TECNICOS (inalterable via trigger, ver mas abajo)
-- ────────────────────────────────────────────────────────────
CREATE TABLE log_errores_tecnicos (
    error_id             SERIAL PRIMARY KEY,
    modulo               VARCHAR(100) NOT NULL,
    descripcion_tecnica  TEXT NOT NULL,
    nivel_criticidad     VARCHAR(20) NOT NULL CHECK (nivel_criticidad IN ('Informativo', 'Advertencia', 'Critico')),
    fecha_hora           TIMESTAMP DEFAULT NOW(),
    administrador_id     INT REFERENCES administrador(administrador_id)
);
 
-- ────────────────────────────────────────────────────────────
-- 44. PROGRESO_LIQUIDACION_WIZARD
-- ────────────────────────────────────────────────────────────
CREATE TABLE progreso_liquidacion_wizard (
    progreso_id         SERIAL PRIMARY KEY,
    trabajador_id       INT NOT NULL REFERENCES trabajador(trabajador_id),
    periodo             VARCHAR(7) NOT NULL,
    paso_actual         INT NOT NULL DEFAULT 0,
    administrador_id    INT REFERENCES administrador(administrador_id),
    fecha_actualizacion TIMESTAMP DEFAULT NOW(),
    UNIQUE (trabajador_id, periodo)
);
 
-- ────────────────────────────────────────────────────────────
-- 45. VERIFICACION_CUENTA
-- ────────────────────────────────────────────────────────────
CREATE TABLE verificacion_cuenta (
    verificacion_id   SERIAL PRIMARY KEY,
    cuenta_id         INT NOT NULL REFERENCES cuenta_acceso(cuenta_id),
    token             VARCHAR(100) UNIQUE NOT NULL,
    fecha_creacion    TIMESTAMP DEFAULT NOW(),
    fecha_expiracion  TIMESTAMP NOT NULL,
    usado             BOOLEAN DEFAULT FALSE
);
 
 
-- ══════════════════════════════════════════════════════════════
-- TRIGGERS: logs de auditoria inalterables
-- ══════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION bloquear_modificacion_log()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Los registros de auditoria son inalterables: no se permite % en esta tabla', TG_OP;
END;
$$ LANGUAGE plpgsql;
 
CREATE TRIGGER trg_bloquear_update_log_auditoria
    BEFORE UPDATE OR DELETE ON log_auditoria
    FOR EACH ROW EXECUTE FUNCTION bloquear_modificacion_log();
 
CREATE TRIGGER trg_bloquear_update_log_errores
    BEFORE UPDATE OR DELETE ON log_errores_tecnicos
    FOR EACH ROW EXECUTE FUNCTION bloquear_modificacion_log();

-- El trigger de arriba bloquea fila por fila; estos 2 cubren TRUNCATE
-- (que vaciaria la tabla completa sin pasar por el trigger de fila).
CREATE TRIGGER trg_bloquear_truncate_log_auditoria
    BEFORE TRUNCATE ON log_auditoria
    FOR EACH STATEMENT EXECUTE FUNCTION bloquear_modificacion_log();

CREATE TRIGGER trg_bloquear_truncate_log_errores
    BEFORE TRUNCATE ON log_errores_tecnicos
    FOR EACH STATEMENT EXECUTE FUNCTION bloquear_modificacion_log();
 
 
-- ══════════════════════════════════════════════════════════════
-- VISTAS
-- ══════════════════════════════════════════════════════════════
CREATE OR REPLACE VIEW v_login AS
SELECT ca.cuenta_id, ca.correo_institucional, ca.contrasena,
       ca.rol, ca.bloqueada, ca.intentos_fallidos, ca.bloqueada_hasta,
       ca.cuenta_verificada,
       p.persona_id, p.rut, p.primer_nombre, p.apellido_paterno,
       p.apellido_materno, p.cargo, p.activo
FROM cuenta_acceso ca
LEFT JOIN persona p ON p.persona_id = ca.persona_id;
 
CREATE OR REPLACE VIEW v_resumen_empleados AS
SELECT p.persona_id, p.rut, p.primer_nombre, p.apellido_paterno,
       p.apellido_materno, p.cargo, p.fecha_ingreso, p.correo_institucional,
       c.tipo_contrato, c.sueldo_base, c.fecha_vencimiento,
       d.nombre AS departamento, d.codigo AS codigo_depto,
       sv.dias_disponibles AS saldo_vacaciones,
       ca.rol
FROM persona p
JOIN trabajador t ON t.persona_id = p.persona_id
JOIN cuenta_acceso ca ON ca.persona_id = p.persona_id
LEFT JOIN contrato c ON c.trabajador_id = t.trabajador_id AND c.estado = 'activo'
LEFT JOIN departamento d ON d.departamento_id = t.departamento_id
LEFT JOIN saldo_vacaciones sv ON sv.trabajador_id = t.trabajador_id;
 
CREATE OR REPLACE VIEW v_ultima_liquidacion AS
SELECT DISTINCT ON (p.rut)
       lp.liquidacion_pdf_id AS id, p.rut, lp.periodo, lp.nombre_archivo,
       lp.fecha_subida, lp.tamano_bytes,
       p.primer_nombre, p.apellido_paterno
FROM liquidaciones_pdf lp
JOIN trabajador t ON t.trabajador_id = lp.trabajador_id
JOIN persona p ON p.persona_id = t.persona_id
ORDER BY p.rut, lp.periodo DESC;
