-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2019-05-06 22:16:21.428

-- tables
-- Table: ALQUILER
CREATE TABLE ALQUILER (
    id_alquiler int  NOT NULL,
    id_cliente int  NOT NULL,
    fecha_desde date  NOT NULL,
    fecha_hasta date  NULL,
    importe_dia decimal(10,2)  NOT NULL,
    CONSTRAINT PK_ALQUILER PRIMARY KEY (id_alquiler)
);

-- Table: ALQUILER_POSICIONES
CREATE TABLE ALQUILER_POSICIONES (
    id_alquiler int  NOT NULL,
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    estado boolean  NOT NULL,
    CONSTRAINT PK_ALQUILER_POSICIONES PRIMARY KEY (id_alquiler,nro_posicion,nro_estanteria,nro_fila)
);

-- Table: CLIENTE
CREATE TABLE CLIENTE (
    cuit_cuil int  NOT NULL,
    apellido varchar(60)  NOT NULL,
    nombre varchar(40)  NOT NULL,
    fecha_alta date  NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (cuit_cuil)
);

-- Table: ESTANTERIA
CREATE TABLE ESTANTERIA (
    nro_estanteria int  NOT NULL,
    nombre_estanteria varchar(80)  NOT NULL,
    CONSTRAINT PK_ESTANTERIA PRIMARY KEY (nro_estanteria)
);

-- Table: FILA
CREATE TABLE FILA (
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    nombre_fila varchar(80)  NOT NULL,
    peso_max_kg decimal(10,2)  NOT NULL,
    CONSTRAINT PK_FILA PRIMARY KEY (nro_estanteria,nro_fila)
);

-- Table: MOVIMIENTO
CREATE TABLE MOVIMIENTO (
    id_movimiento int  NOT NULL,
    fecha timestamp  NOT NULL,
    responsable varchar(80)  NOT NULL,
    tipo char(1)  NOT NULL,
    CONSTRAINT PK_MOVIMIENTO PRIMARY KEY (id_movimiento)
);

-- Table: MOV_ENTRADA
CREATE TABLE MOV_ENTRADA (
    id_movimiento int  NOT NULL,
    transporte varchar(80)  NOT NULL,
    guia varchar(80)  NOT NULL,
    cod_pallet varchar(20)  NOT NULL,
    id_alquiler int  NOT NULL,
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    CONSTRAINT PK_MOV_ENTRADA PRIMARY KEY (id_movimiento)
);

-- Table: MOV_INTERNO
CREATE TABLE MOV_INTERNO (
    id_movimiento int  NOT NULL,
    razon varchar(200)  NULL,
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    CONSTRAINT PK_MOV_INTERNO PRIMARY KEY (id_movimiento)
);

-- Table: MOV_SALIDA
CREATE TABLE MOV_SALIDA (
    id_movimiento int  NOT NULL,
    transporte varchar(80)  NOT NULL,
    guia varchar(80)  NOT NULL,
    CONSTRAINT PK_MOV_SALIDA PRIMARY KEY (id_movimiento)
);

-- Table: PALLET
CREATE TABLE PALLET (
    cod_pallet varchar(20)  NOT NULL,
    descripcion varchar(200)  NOT NULL,
    peso decimal(10,2)  NOT NULL,
    CONSTRAINT PK_PALLET PRIMARY KEY (cod_pallet)
);

-- Table: POSICION
CREATE TABLE POSICION (
    nro_posicion int  NOT NULL,
    nro_estanteria int  NOT NULL,
    nro_fila int  NOT NULL,
    tipo varchar(40)  NOT NULL,
    CONSTRAINT PK_POSICION PRIMARY KEY (nro_posicion,nro_estanteria,nro_fila)
);

-- foreign keys
-- Reference: FK_ALQUILER_CLIENTE (table: ALQUILER)
ALTER TABLE ALQUILER ADD CONSTRAINT FK_ALQUILER_CLIENTE
    FOREIGN KEY (id_cliente)
    REFERENCES CLIENTE (cuit_cuil)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_ALQUILER_POSICIONES_ALQUILER (table: ALQUILER_POSICIONES)
ALTER TABLE ALQUILER_POSICIONES ADD CONSTRAINT FK_ALQUILER_POSICIONES_ALQUILER
    FOREIGN KEY (id_alquiler)
    REFERENCES ALQUILER (id_alquiler)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_ALQUILER_POSICIONES_POSICION (table: ALQUILER_POSICIONES)
ALTER TABLE ALQUILER_POSICIONES ADD CONSTRAINT FK_ALQUILER_POSICIONES_POSICION
    FOREIGN KEY (nro_posicion, nro_estanteria, nro_fila)
    REFERENCES POSICION (nro_posicion, nro_estanteria, nro_fila)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_FILA_ESTANTERIA (table: FILA)
ALTER TABLE FILA ADD CONSTRAINT FK_FILA_ESTANTERIA
    FOREIGN KEY (nro_estanteria)
    REFERENCES ESTANTERIA (nro_estanteria)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_ENTRADA_ALQUILER_POSICIONES (table: MOV_ENTRADA)
ALTER TABLE MOV_ENTRADA ADD CONSTRAINT FK_MOV_ENTRADA_ALQUILER_POSICIONES
    FOREIGN KEY (id_alquiler, nro_posicion, nro_estanteria, nro_fila)
    REFERENCES ALQUILER_POSICIONES (id_alquiler, nro_posicion, nro_estanteria, nro_fila)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_ENTRADA_MOVIMIENTO (table: MOV_ENTRADA)
ALTER TABLE MOV_ENTRADA ADD CONSTRAINT FK_MOV_ENTRADA_MOVIMIENTO
    FOREIGN KEY (id_movimiento)
    REFERENCES MOVIMIENTO (id_movimiento)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_ENTRADA_PALLET (table: MOV_ENTRADA)
ALTER TABLE MOV_ENTRADA ADD CONSTRAINT FK_MOV_ENTRADA_PALLET
    FOREIGN KEY (cod_pallet)
    REFERENCES PALLET (cod_pallet)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_INTERNO_MOVIMIENTO (table: MOV_INTERNO)
ALTER TABLE MOV_INTERNO ADD CONSTRAINT FK_MOV_INTERNO_MOVIMIENTO
    FOREIGN KEY (id_movimiento)
    REFERENCES MOVIMIENTO (id_movimiento)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_INTERNO_POSICION (table: MOV_INTERNO)
ALTER TABLE MOV_INTERNO ADD CONSTRAINT FK_MOV_INTERNO_POSICION
    FOREIGN KEY (nro_posicion, nro_estanteria, nro_fila)
    REFERENCES POSICION (nro_posicion, nro_estanteria, nro_fila)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_MOV_SALIDA_MOVIMIENTO (table: MOV_SALIDA)
ALTER TABLE MOV_SALIDA ADD CONSTRAINT FK_MOV_SALIDA_MOVIMIENTO
    FOREIGN KEY (id_movimiento)
    REFERENCES MOVIMIENTO (id_movimiento)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_POSICION_FILA (table: POSICION)
ALTER TABLE POSICION ADD CONSTRAINT FK_POSICION_FILA
    FOREIGN KEY (nro_estanteria, nro_fila)
    REFERENCES FILA (nro_estanteria, nro_fila)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.

