-- Control de consistencia de fechas (Fecha desde no debe ser mayor a fecha hasta)
ALTER TABLE GR17_ALQUILER ADD CONSTRAINT CHK_GR17_ALQUILER_CONSISTENTE_FECHA CHECK (
    to_char(fecha_desde, 'YYYY-MM-DD') <= to_char(fecha_hasta, 'YYYY-MM-DD')
);
--INSERCION PROMUEVE RESTRICCION CHK_GR17_ALQUILER_CONSISTENTE_FECHA:
/*
--INSERT INTO GR17_ALQUILER(id_alquiler, id_cliente, fecha_desde, fecha_hasta, importe_dia)
VALUES (6, 1, '2019-12-12', '2019-01-01');
*/

-- Control de tipos posibles de posicion 
ALTER TABLE GR17_POSICION ADD CONSTRAINT CHK_GR17_POSICION_TIPO CHECK (
    tipo IN ('general', 'vidrio', 'insecticidas', 'inflamable')
);

--INSERCION PROMUEVE RESTRICCION CHK_GR17_POSICION_TIPO:
/*
INSERT INTO GR17_POSICION (nro_posicion, nro_estanteria, nro_fila, tipo, pos_global) VALUES
(17, 1, 1, 'Radioactivo', 001001017);
*/

-- Restriccion para que la tabla MOV_INTERNO no pueda referir a un movimiento
-- interno y a uno de entrada a la vez, y que tampoco puedan ser ambos nulos
ALTER TABLE GR17_MOV_INTERNO ADD CONSTRAINT CHK_GR17_MOVIMIENTO_INTERNO_REFERENCIAS CHECK(
    (id_movimiento_entrada IS NOT NULL AND id_movimiento_interno IS NULL) OR 
    (id_movimiento_entrada IS NULL AND id_movimiento_interno IS NOT NULL)
);
-- INSERCION QUE PROMUEVE RESTRICCION CHK_GR17_MOVIMIENTO_INTERNO_REFERENCIAS
/*
INSERT INTO GR17_MOV_INTERNO (id_movimiento, razon, nro_posicion, nro_estanteria, nro_fila, id_movimiento_entrada, id_movimiento_interno) VALUES
(1, 'Optimizacion', 2, 1, 1, null, null);
*/

-- LOS SIGUIENTES TRIGGERS/FUNCIO|NES CHECKEAN QUE EL PESO MAXIMO TOLERADO POR LA 
-- FILA NO SE SOBREPASE

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

-- Tigger para verificar peso de fila cada vez q se inserta 
CREATE TRIGGER TR_GR17_MOV_ENTRADA_VERIFICAR_PESO_FILA 
AFTER INSERT 
ON GR17_MOV_ENTRADA for each row
EXECUTE PROCEDURE TRFN_GR17_verificarPeso();


--INSERCION QUE PROMUEVE RESTRICCION TR_GR17_MOV_ENTRADA_VERIFICAR_PESO_FILA:
/*
INSERT INTO GR17_MOVIMIENTO (id_movimiento, fecha, responsable, tipo) VALUES
(20, '02-15-2019', 'Eloy', 'e');
INSERT INTO GR17_PALLET (cod_pallet, descripcion, peso) VALUES
(20, 'Juguetes', 8.00);
INSERT INTO GR17_MOV_ENTRADA (id_movimiento, transporte, guia,cod_pallet,id_alquiler,nro_posicion,nro_estanteria,nro_fila) VALUES
(20, 'Zampi', 'A', 20,1,1,1,1);
*/


-- lOS SIGUIENTES TRIGGERS/FUNCIONES HACEN EL UPDATE DEL ESTADO DE
-- ALQUILER_POSICIONES AL REALIZAR UN  MOVIMIENTO



-- Actualiza el estado de la posicion al ingresar un nuevo pallet
CREATE OR REPLACE FUNCTION TRFN_GR17_actualizarEstadoPosicion() 
RETURNS TRIGGER AS $BODY$
BEGIN 
    UPDATE GR17_ALQUILER_POSICIONES 
    SET estado='true'
    WHERE nro_posicion=new.nro_posicion AND nro_fila=new.nro_fila AND nro_estanteria=new.nro_estanteria AND id_alquiler=new.id_alquiler;
RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

-- Trigger para modificar estado al ingresar un pallet
CREATE TRIGGER TR_GR17_ACTUALIZAR_ESTADO_MOV_ENTRADA
AFTER INSERT OR UPDATE OF nro_estanteria, nro_fila, nro_posicion, id_alquiler
ON GR17_MOV_ENTRADA FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR17_actualizarEstadoPosicion();


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

-- Trigger para modificar estado al quitar  un pallet
CREATE TRIGGER TR_GR17_ACTUALIZAR_ESTADO_MOV_SALIDA
AFTER INSERT
ON GR17_MOV_SALIDA FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR17_actualizarEstadoPosicion_salida();



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


-- Trigger para modificar estado al realizar un movimiento interno  un pallet
CREATE TRIGGER TR_GR17_ACTUALIZAR_ESTADO_MOV_INTERNO
AFTER INSERT
ON GR17_MOV_INTERNO FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR17_actualizarEstadoPosicion_interno();

-- FUNCIONES PARA REALIZAR LOS SERVICIOS DEL PUNTO C

-- C-1 Obtener posiciones libres dada una fecha
-- PARAMETRO RECOMENDADO PARA PROBAR '2019-01-05'
CREATE OR REPLACE FUNCTION FN_GR17_getPosicionesLibres(date) 
RETURNS SETOF GR17_POSICION AS $BODY$
DECLARE
    r GR17_POSICION%rowtype;
BEGIN 
    FOR r IN
        SELECT nro_estanteria, nro_fila, nro_posicion
        FROM GR17_ALQUILER_POSICIONES 
        WHERE id_alquiler NOT IN (
            SELECT id_alquiler 
            FROM GR17_ALQUILER
            WHERE fecha_desde < $1 AND fecha_hasta > $1
        )
        UNION
        SELECT nro_estanteria , nro_fila, nro_posicion
        FROM GR17_POSICION
        WHERE (nro_posicion, nro_estanteria, nro_fila) NOT IN (
            SELECT nro_posicion, nro_estanteria, nro_fila 
            FROM GR17_ALQUILER_POSICIONES
        )
    LOOP
        RETURN NEXT r;
    END LOOP;
    RETURN;
END;
$BODY$ LANGUAGE plpgsql;


-- C-2. Obtener los datos de los clientes a los cuales hay que notificar que el alquiler se vence en x dias (Configurable)
-- Para probar se recomienda:
-- 1. Insertar Siguiente Alquieler:
/*
INSERT INTO GR17_ALQUILER (id_alquiler,id_cliente,fecha_desde,fecha_hasta,importe_dia) VALUES
(7,5,'05-01-2017',CURRENT_DATE + interval '7 day',5);
*/
-- 2- Proveer siguiente parametro (dias): 7
CREATE OR REPLACE FUNCTION FN_GR17_getClientesANotificar(integer) 
RETURNS SETOF GR17_CLIENTE AS $BODY$
DECLARE
    r GR17_CLIENTE%rowtype;
BEGIN 
    FOR r IN
        SELECT *
        FROM GR17_CLIENTE c
        JOIN GR17_ALQUILER a ON (a.id_cliente = c.cuit_cuil)
        WHERE fecha_hasta - $1 = CURRENT_DATE
    LOOP
        RETURN NEXT r;
    END LOOP;
    RETURN;
END;
$BODY$ LANGUAGE plpgsql;

-- VISTAS
-- D1 -  - Vista que indica el estado de cada posicion junto con los
-- dias restantes de alquiler en caso de ser TRUE su estado (es decir que 
-- la posicion este alquilada)

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
WHERE estado=true;


-- Funcion para calcular la cantidad de dias que un cliente facturo el ultimo año.
CREATE OR REPLACE FUNCTION GR17_FN_getCantDias(date,date)
RETURNS integer AS $$
DECLARE 
 aYearBefore date := CURRENT_DATE - interval '1 year';
 desde ALIAS FOR $1;
 hasta ALIAS FOR $2;
BEGIN
    IF desde > CURRENT_DATE OR hasta < aYearBefore THEN 
        RETURN 0;
    ELSIF desde >= aYearBefore AND hasta <= CURRENT_DATE THEN 
        RETURN hasta - desde;
    ELSIF desde <= aYearBefore AND hasta <= CURRENT_DATE THEN
        RETURN  hasta - aYearBefore;
    ELSIF desde >= aYearBefore AND hasta >= CURRENT_DATE THEN
        RETURN CURRENT_DATE - desde;
    ELSIF desde < aYearBefore AND hasta > CURRENT_DATE THEN
        RETURN 365;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- D-2  Vista que lista  los 10 clientes que más dinero han invertido en el último año (tomar el momento en el que se ejecuta la consulta hacia atrás).
CREATE VIEW GR17_CLIENTES_MAS_VALIOSOS AS
SELECT getCantDias(a.fecha_desde, a.fecha_hasta) * a.importe_dia AS “Importe”, a.id_cliente, c.nombre, c.apellido 
FROM GR17_ALQUILER a
JOIN GR17_CLIENTE c ON (c.cuit_cuil = a.id_cliente)
WHERE getCantDias(a.fecha_desde, a.fecha_hasta) * a.importe_dia > 0
ORDER BY 1 desc
LIMIT 10;

