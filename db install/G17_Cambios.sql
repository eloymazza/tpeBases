-- Control de consistencia de fechas (Fecha desde no debe ser mayor a fecha hasta)
ALTER TABLE GR17_ALQUILER ADD CONSTRAINT CHK_GR17_ALQUILER_CONSISTENTE_FECHA CHECK (
    to_char(fecha_desde, 'YYYY-MM-DD') <= to_char(fecha_hasta, 'YYYY-MM-DD')
    OR fecha_desde IS NULL
);

-- Control de tipos posibles de posicion 
ALTER TABLE GR17_POSICION ADD CONSTRAINT CHK_GR17_POSICION_TIPO CHECK (
    tipo IN ('general', 'vidrio', 'insecticidas', 'inflamable')
);

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
CREATE OR REPLACE FUNCTION sumaPesoFila(int,int) 
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
CREATE OR REPLACE FUNCTION getMaxPeso(int, int) 
RETURNS numeric AS $$
BEGIN
    RETURN  
        (SELECT peso_max_kg 
        FROM GR17_FILA 
        WHERE nro_fila= $1 AND nro_estanteria=$2);
END;
$$ LANGUAGE plpgsql;

-- Tigger para verificar peso de fila cada vez q se inserta 
-- o actualiza un movimiento de entrada
CREATE TRIGGER TR_GR17_MOV_ENTRADA_VERIFICAR_PESO_FILA 
AFTER INSERT OR UPDATE 
ON GR17_MOV_ENTRADA for each row
EXECUTE PROCEDURE TRFN_GR17_verificarpeso();
