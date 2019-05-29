-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2019-05-06 22:16:21.428

-- tables
-- Table: ALQUILER
CREATE TABLE GR17_ALQUILER (
    id_alquiler int  NOT NULL,
    id_cliente int  NOT NULL,
    fecha_desde date  NOT NULL,
    fecha_hasta date  NULL,
    importe_dia decimal(10,2)  NOT NULL,
    CONSTRAINT PK_GR17_ALQUILER PRIMARY KEY (id_alquiler)
);

-- Table: ALQUILER_POSICIONES
CREATE TABLE GR17_ALQUILER_POSICIONES (
    id_alquiler int  NOT NULL,
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    estado boolean  NOT NULL,
    CONSTRAINT PK_GR17_ALQUILER_POSICIONES PRIMARY KEY (id_alquiler,nro_posicion,nro_estanteria,nro_fila)
);

-- Table: CLIENTE
CREATE TABLE GR17_CLIENTE (
    cuit_cuil int  NOT NULL,
    apellido varchar(60)  NOT NULL,
    nombre varchar(40)  NOT NULL,
    fecha_alta date  NOT NULL,
    CONSTRAINT GR17_PK_CLIENTE PRIMARY KEY (cuit_cuil)
);

-- Table: ESTANTERIA
CREATE TABLE GR17_ESTANTERIA (
    nro_estanteria int  NOT NULL,
    nombre_estanteria varchar(80)  NOT NULL,
    CONSTRAINT PK_GR17_ESTANTERIA PRIMARY KEY (nro_estanteria)
);

-- Table: FILA
CREATE TABLE GR17_FILA (
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    nombre_fila varchar(80)  NOT NULL,
    peso_max_kg decimal(10,2)  NOT NULL,
    alto_mts decimal(4,2),
    CONSTRAINT PK_GR17_FILA PRIMARY KEY (nro_estanteria,nro_fila)
);

-- Table: MOVIMIENTO
CREATE TABLE GR17_MOVIMIENTO (
    id_movimiento int  NOT NULL,
    fecha timestamp  NOT NULL,
    responsable varchar(80)  NOT NULL,
    tipo char(1)  NOT NULL,
    CONSTRAINT PK_GR17_MOVIMIENTO PRIMARY KEY (id_movimiento)
);

-- Table: MOV_ENTRADA
CREATE TABLE GR17_MOV_ENTRADA (
    id_movimiento int  NOT NULL,
    transporte varchar(80)  NOT NULL,
    guia varchar(80)  NOT NULL,
    cod_pallet varchar(20)  NOT NULL,
    id_alquiler int  NOT NULL,
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    CONSTRAINT PK_GR17_MOV_ENTRADA PRIMARY KEY (id_movimiento)
);

-- Table: MOV_INTERNO
CREATE TABLE GR17_MOV_INTERNO (
    id_movimiento int  NOT NULL,
    razon varchar(200)  NULL,
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    CONSTRAINT PK_GR17_MOV_INTERNO PRIMARY KEY (id_movimiento)
);

-- Table: MOV_SALIDA
CREATE TABLE GR17_MOV_SALIDA (
    id_movimiento int  NOT NULL,
    transporte varchar(80)  NOT NULL,
    guia varchar(80)  NOT NULL,
    CONSTRAINT PK_GR17_MOV_SALIDA PRIMARY KEY (id_movimiento)
);

-- Table: PALLET
CREATE TABLE GR17_PALLET (
    cod_pallet varchar(20)  NOT NULL,
    descripcion varchar(200)  NOT NULL,
    peso decimal(10,2)  NOT NULL,
    CONSTRAINT PK_GR17_PALLET PRIMARY KEY (cod_pallet)
);

-- Table: POSICION
CREATE TABLE GR17_POSICION (
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    tipo varchar(40)  NOT NULL,
    pos_global int NOT NULL,
    CONSTRAINT PK_GR17_POSICION PRIMARY KEY (nro_posicion,nro_estanteria,nro_fila)
);

-- foreign keys
-- Reference: FK_ALQUILER_CLIENTE (table: ALQUILER)
ALTER TABLE GR17_ALQUILER ADD CONSTRAINT FK_GR17_ALQUILER_CLIENTE
    FOREIGN KEY (id_cliente)
    REFERENCES GR17_CLIENTE (cuit_cuil)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_ALQUILER_POSICIONES_ALQUILER (table: ALQUILER_POSICIONES)
ALTER TABLE GR17_ALQUILER_POSICIONES ADD CONSTRAINT FK_GR17_ALQUILER_POSICIONES_ALQUILER
    FOREIGN KEY (id_alquiler)
    REFERENCES GR17_ALQUILER (id_alquiler)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_ALQUILER_POSICIONES_POSICION (table: ALQUILER_POSICIONES)
ALTER TABLE GR17_ALQUILER_POSICIONES ADD CONSTRAINT FK_GR17_ALQUILER_POSICIONES_POSICION
    FOREIGN KEY (nro_posicion, nro_estanteria, nro_fila)
    REFERENCES GR17_POSICION (nro_posicion, nro_estanteria, nro_fila)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_FILA_ESTANTERIA (table: FILA)
ALTER TABLE GR17_FILA ADD CONSTRAINT FK_GR17_FILA_ESTANTERIA
    FOREIGN KEY (nro_estanteria)
    REFERENCES GR17_ESTANTERIA (nro_estanteria)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_ENTRADA_ALQUILER_POSICIONES (table: MOV_ENTRADA)
ALTER TABLE GR17_MOV_ENTRADA ADD CONSTRAINT FK_GR17_MOV_ENTRADA_ALQUILER_POSICIONES
    FOREIGN KEY (id_alquiler, nro_posicion, nro_estanteria, nro_fila)
    REFERENCES GR17_ALQUILER_POSICIONES (id_alquiler, nro_posicion, nro_estanteria, nro_fila)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_ENTRADA_MOVIMIENTO (table: MOV_ENTRADA)
ALTER TABLE GR17_MOV_ENTRADA ADD CONSTRAINT FK_GR17_MOV_ENTRADA_MOVIMIENTO
    FOREIGN KEY (id_movimiento)
    REFERENCES GR17_MOVIMIENTO (id_movimiento)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_ENTRADA_PALLET (table: MOV_ENTRADA)
ALTER TABLE GR17_MOV_ENTRADA ADD CONSTRAINT FK_GR17_MOV_ENTRADA_PALLET
    FOREIGN KEY (cod_pallet)
    REFERENCES GR17_PALLET (cod_pallet)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_INTERNO_MOVIMIENTO (table: MOV_INTERNO)
ALTER TABLE GR17_MOV_INTERNO ADD CONSTRAINT FK_GR17_MOV_INTERNO_MOVIMIENTO
    FOREIGN KEY (id_movimiento)
    REFERENCES GR17_MOVIMIENTO (id_movimiento)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_INTERNO_POSICION (table: MOV_INTERNO)
ALTER TABLE GR17_MOV_INTERNO ADD CONSTRAINT FK_GR17_MOV_INTERNO_POSICION
    FOREIGN KEY (nro_posicion, nro_estanteria, nro_fila)
    REFERENCES GR17_POSICION (nro_posicion, nro_estanteria, nro_fila)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_SALIDA_MOVIMIENTO (table: MOV_SALIDA)
ALTER TABLE GR17_MOV_SALIDA ADD CONSTRAINT FK_GR17_MOV_SALIDA_MOVIMIENTO
    FOREIGN KEY (id_movimiento)
    REFERENCES GR17_MOVIMIENTO (id_movimiento)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_POSICION_FILA (table: POSICION)
ALTER TABLE GR17_POSICION ADD CONSTRAINT FK_GR17_POSICION_FILA
    FOREIGN KEY (nro_estanteria, nro_fila)
    REFERENCES GR17_FILA (nro_estanteria, nro_fila)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Unique constrants
ALTER TABLE GR17_POSICION ADD CONSTRAINT UQ_GR17_POSICION_POS_GLOBAL
    UNIQUE (pos_global)
;

-- End of file.

-- Inserts

INSERT INTO GR17_CLIENTE (cuit_cuil,apellido,nombre,fecha_alta) VALUES
(1, 'Lord', 'Farcuat', '01/25/2018'),
(2, 'Carlos', 'Martel', '05/19/2014'),
(3, 'Daenerys', 'Targeryen', '07/12/2017'),
(4, 'Marco', 'Polo', '11/15/2018'),
(5, 'John', 'Snow', '12/27/2019');


INSERT INTO GR17_ALQUILER (id_alquiler,id_cliente,fecha_desde,fecha_hasta,importe_dia) VALUES
(1,1,'03-06-2019','07-01-2019',10),
(2,2,'02-16-2019','12-01-2019',15),
(3,3,'03-11-2018','05-12-2019',12),
(4,4,'01-22-2019','02-05-2019',20),
(5,5,'04-28-2017','05-10-2019',5);

INSERT INTO GR17_ESTANTERIA (nro_estanteria, nombre_estanteria) VALUES
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D'),
(5, 'E');

INSERT INTO GR17_FILA (nro_estanteria, nro_fila, nombre_fila, peso_max_kg, alto_mts) VALUES
(1, 1, 'A1'),
(2, 1, 'B1'),
(3, 7, 'C7'),
(4, 4, 'D4'),
(5, 2, 'E2');

INSERT INTO GR17_POSICION (nro_posicion, nro_estanteria, nro_fila, tipo, pos_global) VALUES
(1, 1, 1, "a", 001001001),
(2, 2, 1, "b", 002002001),
(3, 3, 7, "c", 003003007),
(4, 4, 4, "a", 004004004),
(5, 5, 2, "d", 005005005);

INSERT INTO GR17_ALQUILER_POSICIONES (id_alquiler, nro_posicion, nro_estanteria, nro_fila, estado) VALUES
(1, 1, 1, 1, true),
(2, 2, 2, 1, true),
(3, 3, 3, 7, false),
(4, 4, 4, 4, false),
(5, 5, 5, 2, false);


INSERT INTO GR17_PALLET (cod_pallet, descripcion, peso) VALUES
(1, "Juguetes", 8.00),
(2, "Herramientas", 100.00),
(3, "Hardware", 50.00),
(4, "Medicamentos", 20.00),
(5, "Patentes truchas", 17.00);


INSERT INTO GR17_MOVIMIENTO (id_movimiento, fecha, responsable, tipo) VALUES
(1, '02-22-2019', 'Juan', 'e'),
(2, '02-21-2019', 'Pedro', 'e'),
(3, '03-12-2018', 'Johana', 'e'),
(4, '01-23-2019', 'Isabel', 'e'),
(5, '04-29-2017', 'Oscar', 'e');
(6, '03-23-2019', 'Juan', 'i'),
(7, '02-24-2019', 'Pedro', 'i'),
(8, '03-15-2018', 'Johana', 'i'),
(9, '01-25-2019', 'Isabel', 'i'),
(10, '05-01-2019', 'Isabel', 'i'),
(11, '04-29-2017', 'Oscar', 's');
(12, '04-22-2019', 'Juan', 's'),
(13, '04-21-2019', 'Pedro', 's'),
(14, '02-12-2018', 'Johana', 's'),
(15, '05-23-2019', 'Isabel', 's'),


INSERT INTO GR17_MOV_SALIDA (id_movimiento, transporte, guia) VALUES
(11, 'Zampi', 'A'),
(12, 'Zampi', 'B'),
(13, 'Camioneta', 'C'),
(14, 'Camion', 'D'),
(15, 'Particular', 'E');
/*
INSERT INTO GR17_MOV_INTERNO (id_movimiento, razon, nro_posicion, nro_estanteria, nro_fila) VALUES
(6, 'Optimizacion', 1, 1, 1),
(7, 'Otros', 2, 2, 1),
(8, 'Optimizacion', 3, 3, 7),
(9, 'Pedido Cliente', nro_posicion, nro_estanteria, nro_estanteria),
(10, 'Otros', nro_posicion, nro_estanteria, nro_estanteria);

*/



