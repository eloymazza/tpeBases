-- Control de consistencia de fechas (Fecha desde no debe ser mayor a fecha hasta)
ALTER TABLE GR17_ALQUILER ADD CONSTRAINT CHK_GR17_ALQUILER_CONSISTENTE_FECHA CHECK (
    to_char(fecha_desde, 'YYYY-MM-DD') <= to_char(fecha_hasta, 'YYYY-MM-DD')
    OR fecha_desde IS NULL
);

-- Control de tipos posibles de posicion 
ALTER TABLE GR17_POSICION ADD CONSTRAINT CHK_GR17_POSICION_TIPO CHECK (
    tipo IN ('general', 'vidrio', 'insecticidas', 'inflamable')
);

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


