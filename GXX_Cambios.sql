-- Control de consistencia de fechas (Fecha desde no debe ser mayor a fecha hasta)
ALTER TABLE GRXX_ALQUILER ADD CONSTRAINT CHK_GRXX_ALQUILER_CONSISTENTE_FECHA CHECK (
    to_char(fecha_desde, 'YYYY-MM-DD') <= to_char(fecha_hasta, 'YYYY-MM-DD')
    OR fecha_desde IS NULL
);

-- Control de tipos posibles de posicion 
ALTER TABLE GRXX_POSICION ADD CONSTRAINT CHK_GRXX_POSICION_TIPO CHECK (
    tipo IN ('general', 'vidrio', 'insecticidas', 'inflamable');
);