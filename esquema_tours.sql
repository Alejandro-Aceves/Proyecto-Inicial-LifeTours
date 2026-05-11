-- Script de creación de base de datos para Sistema de Tours
-- Basado en el esquema proporcionado

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tabla USUARIO
CREATE TABLE USUARIO (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    password_hash TEXT NOT NULL,
    foto_url TEXT,
    rol VARCHAR(20) CHECK (rol IN ('turista', 'guia', 'admin')),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabla GUIA
CREATE TABLE GUIA (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL UNIQUE,
    bio TEXT,
    idiomas VARCHAR(200),
    calificacion_promedio DECIMAL(3,2) DEFAULT 0.00,
    num_resenas INT DEFAULT 0,
    certificaciones TEXT,
    disponible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (usuario_id) REFERENCES USUARIO(id) ON DELETE CASCADE
);

-- 3. Tabla CATEGORIA
CREATE TABLE CATEGORIA (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(80) NOT NULL,
    descripcion TEXT,
    icono_url TEXT,
    activa BOOLEAN DEFAULT TRUE
);

-- 4. Tabla TOUR
CREATE TABLE TOUR (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guia_id UUID NOT NULL,
    categoria_id UUID NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    duracion_minutos INT,
    precio DECIMAL(10,2) NOT NULL,
    moneda CHAR(3) DEFAULT 'MXN',
    capacidad_maxima INT,
    ubicacion VARCHAR(200),
    latitud DECIMAL(9,6),
    longitud DECIMAL(9,6),
    estado VARCHAR(20) CHECK (estado IN ('borrador', 'activo', 'pausado')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guia_id) REFERENCES GUIA(id),
    FOREIGN KEY (categoria_id) REFERENCES CATEGORIA(id)
);

-- 5. Tabla ITINERARIO
CREATE TABLE ITINERARIO (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL,
    orden INT NOT NULL,
    titulo VARCHAR(150),
    descripcion TEXT,
    duracion_minutos INT,
    latitud DECIMAL(9,6),
    longitud DECIMAL(9,6),
    FOREIGN KEY (tour_id) REFERENCES TOUR(id) ON DELETE CASCADE
);

-- 6. Tabla MEDIA
CREATE TABLE MEDIA (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL,
    url TEXT NOT NULL,
    tipo VARCHAR(20) CHECK (tipo IN ('imagen', 'video')),
    es_portada BOOLEAN DEFAULT FALSE,
    orden INT,
    FOREIGN KEY (tour_id) REFERENCES TOUR(id) ON DELETE CASCADE
);

-- 7. Tabla DISPONIBILIDAD
CREATE TABLE DISPONIBILIDAD (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    cupos_disponibles INT,
    precio_especial DECIMAL(10,2),
    estado VARCHAR(20) CHECK (estado IN ('abierto', 'lleno', 'cancelado')),
    FOREIGN KEY (tour_id) REFERENCES TOUR(id) ON DELETE CASCADE
);

-- 8. Tabla RESERVACION
CREATE TABLE RESERVACION (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL,
    disponibilidad_id UUID NOT NULL,
    num_personas INT NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    codigo_confirmacion VARCHAR(20) UNIQUE,
    estado VARCHAR(20) CHECK (estado IN ('pendiente', 'confirmada', 'cancelada', 'completada')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES USUARIO(id),
    FOREIGN KEY (disponibilidad_id) REFERENCES DISPONIBILIDAD(id)
);

-- 9. Tabla PAGO
CREATE TABLE PAGO (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservacion_id UUID NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    moneda CHAR(3) DEFAULT 'MXN',
    metodo VARCHAR(20) CHECK (metodo IN ('tarjeta', 'transferencia', 'efectivo')),
    referencia_externa VARCHAR(100),
    estado VARCHAR(20) CHECK (estado IN ('pendiente', 'aprobado', 'fallido', 'reembolsado')),
    procesado_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservacion_id) REFERENCES RESERVACION(id)
);

-- 10. Tabla RESENA
CREATE TABLE RESENA (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservacion_id UUID NOT NULL UNIQUE,
    usuario_id UUID NOT NULL,
    calificacion TINYINT CHECK (calificacion BETWEEN 1 AND 5),
    comentario TEXT,
    respuesta_guia TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservacion_id) REFERENCES RESERVACION(id),
    FOREIGN KEY (usuario_id) REFERENCES USUARIO(id)
);

-- 11. Tabla NOTIFICACION
CREATE TABLE NOTIFICACION (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL,
    titulo VARCHAR(150),
    mensaje TEXT,
    tipo VARCHAR(20) CHECK (tipo IN ('confirmacion', 'recordatorio', 'cancelacion', 'promo')),
    canal VARCHAR(10) CHECK (canal IN ('push', 'email', 'sms')),
    leida BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES USUARIO(id)
);
