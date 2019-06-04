-- Control de consistencia de fechas (Fecha desde no debe ser mayor a fecha hasta)
ALTER TABLE GR17_ALQUILER ADD CONSTRAINT CHK_GR17_ALQUILER_CONSISTENTE_FECHA CHECK (
    to_char(fecha_desde, 'YYYY-MM-DD') <= to_char(fecha_hasta, 'YYYY-MM-DD')
    OR fecha_desde IS NULL
);

-- Control de tipos posibles de posicion 
ALTER TABLE GR17_POSICION ADD CONSTRAINT CHK_GR17_POSICION_TIPO CHECK (
    tipo IN ('general', 'vidrio', 'insecticidas', 'inflamable')
);

-- Restriccion para que la tabla MOV_INTERNO no pueda referir a un movimiento
-- interno y a uno de entrada a la vez, y que tampoco puedan ser ambos nulos
ALTER TABLE GR17_MOV_INTERNO ADD CONSTRAINT CHK_GR17_MOVIMIENTO_INTERNO_REFERENCIAS CHECK(
    (id_movimiento_entrada IS NOT NULL AND id_movimiento_interno IS NULL) OR 
    (id_movimiento_entrada IS NULL AND id_movimiento_interno IS NOT NULL)
);

-- LOS SIGUIENTES TRIGGERS/FUNCIONES CHECKEAN QUE EL PESO MAXIMO TOLERADO POR LA 
-- FILA NO SE SOBREPASE

-- Tigger para verificar peso de fila cada vez q se inserta 
-- o actualiza un movimiento de entrada
CREATE TRIGGER TR_GR17_MOV_ENTRADA_VERIFICAR_PESO_FILA 
AFTER INSERT OR UPDATE 
ON GR17_MOV_ENTRADA for each row
EXECUTE PROCEDURE TRFN_GR17_verificarpeso();

-- El peso de los pallets de una fila no debe superar al máximo de la fila.
CREATE OR REPLACE FUNCTION TRFN_GR17_verificarPeso() 
RETURNS TRIGGER AS $verif$
BEGIN 
    IF sumaPesoFila(new.nro_fila, new.nro_estanteria) > getMaxPeso(new.nro_fila, new.nro_estanteria) 
    THEN RAISE EXCEPTION 'El peso total de los pallets de una fila no pueden superar el  peso máximo de dicha fila';
    END IF;
RETURN NEW;
END;
$verif$ LANGUAGE plpgsql;

-- Sumatoria del peso de todos los pallets dada una fila y una estanteria
CREATE OR REPLACE FUNCTION FN_GR17_sumaPesoFila(int,int) 
RETURNS numeric AS $$
BEGIN
    RETURN  
        (SELECT SUM(peso) 
        FROM GR17_PALLET
        WHERE cod_pallet IN (
            SELECT cod_pallet
            FROM GR17_MOV_ENTRADA
            WHERE nro_fila=$1 AND nro_estanteria=$2)); 
END;
$$ LANGUAGE plpgsql;


-- Obtener Max_Peso dada una fila y una estanteria
CREATE OR REPLACE FUNCTION FN_GR17_getMaxPeso(int, int) 
RETURNS numeric AS $$
BEGIN
    RETURN  
        (SELECT peso_max_kg 
        FROM GR17_FILA 
        WHERE nro_fila= $1 AND nro_estanteria=$2);
END;
$$ LANGUAGE plpgsql;



-- lOS SIGUIENTES TRIGGERS/FUNCIONES HACEN EL UPDATE DEL ESTADO DE
-- ALQUILER_POSICIONES AL REALIZAR UN  MOVIMIENTO

-- Trigger para modificar estado al ingresar un pallet
CREATE TRIGGER TR_GR17_ACTUALIZAR_ESTADO_MOV_ENTRADA
AFTER INSERT OR UPDATE OF nro_estanteria, nro_fila, nro_posicion, id_alquiler
ON GR17_MOV_ENTRADA FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR17_actualizarEstadoPosicion();

-- Actualiza el estado de la posicion al ingresar un nuevo pallet
CREATE OR REPLACE FUNCTION TRFN_GR17_actualizarEstadoPosicion_entrada() 
RETURNS TRIGGER AS $BODY$
BEGIN 
    UPDATE GR17_ALQUILER_POSICIONES 
    SET estado='true'
    WHERE nro_posicion=new.nro_posicion AND nro_fila=new.nro_fila AND nro_estanteria=new.nro_estanteria AND id_alquiler=new.id_alquiler;
RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

-- Trigger para modificar estado al quitar  un pallet
CREATE TRIGGER TR_GR17_ACTUALIZAR_ESTADO_MOV_SALIDA
AFTER INSERT
ON GR17_MOV_SALIDA FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR17_actualizarEstadoPosicion_salida();

-- Actualiza el estado de la posicion al quitar un pallet
CREATE OR REPLACE FUNCTION TRFN_GR17_actualizarEstadoPosicion_salida() 
RETURNS TRIGGER AS $BODY$
BEGIN 
    UPDATE GR17_ALQUILER_POSICIONES 
    SET estado='false'
    WHERE 
    nro_posicion = (SELECT nro_posicion FROM GR17_MOV_ENTRADA WHERE id_movimiento=new.id_movimiento_entrada) AND
    nro_fila =  (SELECT nro_fila FROM GR17_MOV_ENTRADA WHERE id_movimiento=new.id_movimiento_entrada) AND 
    nro_estanteria = (SELECT nro_estanteria FROM GR17_MOV_ENTRADA WHERE id_movimiento=new.id_movimiento_entrada) AND 
    id_alquiler= (SELECT id_alquiler FROM GR17_MOV_ENTRADA WHERE id_movimiento=new.id_movimiento_entrada);
RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;


-- Trigger para modificar estado al realizar un movimiento interno  un pallet
CREATE TRIGGER TR_GR17_ACTUALIZAR_ESTADO_MOV_INTERNO
AFTER INSERT
ON GR17_MOV_INTERNO FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR17_actualizarEstadoPosicion_interno();

-- Actualiza el estado de la posicion al realar un movimiento interno 
CREATE OR REPLACE FUNCTION TRFN_GR17_actualizarEstadoPosicion_interno() 
RETURNS TRIGGER AS $BODY$
BEGIN 
    IF (SELECT tipo FROM GR17_MOVIMIENTO WHERE id_movimiento = new.id_movimiento_anterior) = 'e' THEN
        UPDATE GR17_ALQUILER_POSICIONES 
        SET estado='false'
        WHERE 
        nro_posicion = (SELECT nro_posicion FROM GR17_MOV_ENTRADA WHERE id_movimiento=new.id_movimiento_anterior) AND
        nro_fila =  (SELECT nro_fila FROM GR17_MOV_ENTRADA WHERE id_movimiento=new.id_movimiento_anterior) AND 
        nro_estanteria = (SELECT nro_estanteria FROM GR17_MOV_ENTRADA WHERE id_movimiento=new.id_movimiento_anterior) AND 
        id_alquiler = (SELECT id_alquiler FROM GR17_MOV_ENTRADA WHERE id_movimiento=new.id_movimiento_anterior);

        UPDATE GR17_ALQUILER_POSICIONES
        SET estado='true'
        WHERE nro_posicion = new.nro_posicion 
        AND nro_fila = new.nro_fila 
        AND nro_estanteria = new.nro_estanteria;
    ELSE 
        UPDATE GR17_ALQUILER_POSICIONES 
        SET estado='false'
        WHERE 
        nro_posicion = (SELECT nro_posicion FROM GR17_MOV_INTERNO WHERE id_movimiento=new.id_movimiento_anterior) AND
        nro_fila =  (SELECT nro_fila FROM GR17_MOV_INTERNO WHERE id_movimiento=new.id_movimiento_anterior) AND
        nro_estanteria = (SELECT nro_estanteria FROM GR17_MOV_INTERNO WHERE id_movimiento=new.id_movimiento_anterior);

        UPDATE GR17_ALQUILER_POSICIONES
        SET estado='true'
        WHERE nro_posicion = new.nro_posicion 
        AND nro_fila = new.nro_fila 
        AND nro_estanteria = new.nro_estanteria;
    END IF;
RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;


-- VISTAS
-- Vista que indica el estado de cada posicion junto con los dias restantes de alquiler en caso de ser TRUE su estado (es decir que la posicion este alquilada)

CREATE VIEW GR17_ESTADO_POSICIONES AS 
-- Selecciona todas las posiciones de alquiler_posiciones que no esten siendo ocupadas actualmente
SELECT nro_estanteria, nro_posicion, nro_fila, estado, NULL AS dias_restantes_alquiler 
FROM GR17_ALQUILER_POSICIONES
WHERE estado=false
UNION 
-- Selecciona todas las posiciones de la tabla posicion que no aparezcan en la tabla alquiler_posiciones. Estas no estaran ocupadas
SELECT nro_estanteria, nro_posicion, nro_fila, FALSE, NULL AS dias_restantes_alquiler 
FROM GR17_POSICION 
WHERE (nro_posicion, nro_estanteria, nro_fila) NOT IN (
    SELECT nro_posicion, nro_estanteria, nro_fila 
    FROM GR17_ALQUILER_POSICIONES
)
UNION 
-- Selecciona todas las posiciones ocupadas en la tabla alquiler_posiciones
SELECT nro_estanteria, nro_posicion, nro_fila, estado, text (fecha_hasta - CURRENT_DATE) AS dias_restantes_alquiler
FROM GR17_ALQUILER_POSICIONES ap INNER JOIN GR17_ALQUILER a ON ap.id_alquiler = a.id_alquiler
WHERE estado=true



-- CEMENTERIO DE METODOS
/*
-- Trigger para controlar que cada movimiento interno referencie a otro mov interno
-- O a un movmiento de entrada.
CREATE TRIGGER TR_GR17_MOV_INTERNO_VERIFICAR_MOV_ANTERIOR
AFTER INSERT OR UPDATE OF id_movimiento_anterior
ON GR17_MOV_INTERNO FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR17_verificaMovAnterior();

-- Vefirica movimiento anterior es movimiento interno o movimiento de entrada.
CREATE OR REPLACE FUNCTION TRFN_GR17_verificaMovAnterior() 
RETURNS TRIGGER AS $body$
BEGIN 
    IF FN_GR17_getTipoMovimiento(new.id_movimiento_anterior) = 's' 
    THEN RAISE EXCEPTION 'Los movimientos internos solo pueden hacer referencia
    a un movimiento de entrada o a otro movimiento interno';
    END IF;
RETURN NEW;
END;
$body$ LANGUAGE plpgsql;

-- Retorna el tipo de un movimiento dado un id_movimiento como parametro
CREATE OR REPLACE FUNCTION FN_GR17_getTipoMovimiento(int) 
RETURNS char AS $$
BEGIN 
RETURN (
    SELECT tipo 
    FROM GR17_MOVIMIENTO 
    WHERE id_movimiento = $1
);
END;
$$ LANGUAGE plpgsql;



-- Tirggers para impedir update de las FKs de los movimientos de entrada
CREATE TRIGGER TR_GR17_IMPEDIR_UPDATE_FK_MOVIMIENTO_ENTRADA
BEFORE UPDATE OF id_alquiler, id_movimiento, cod_pallet, nro_posicion, nro_estanteria, nro_fila
ON GR17_MOV_ENTRADA FOR STATEMENT
EXECUTE PROCEDURE TRFN_GR17_excepcionAlActualizarMov();

-- Tirggers para impedir update de las FKs los movimientos de salida
CREATE TRIGGER TR_GR17_IMPEDIR_UPDATE_FK_MOVIMIENTO_SALIDA
BEFORE UPDATE OF 
ON GR17_MOV_ENTRADA FOR STATEMENT
EXECUTE PROCEDURE TRFN_GR17_excepcionAlActualizarMov();

-- Actualiza el estado de la posicion al quitar un pallet
CREATE OR REPLACE FUNCTION TRFN_GR17_excepcionAlActualizarMov() 
RETURNS TRIGGER AS $BODY$
BEGIN 
RAISE EXCEPTION 'No puedes editar las FKs de movimientos';
END;
$BODY$ LANGUAGE plpgsql;*/
