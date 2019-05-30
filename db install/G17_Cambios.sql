-- Control de consistencia de fechas (Fecha desde no debe ser mayor a fecha hasta)
ALTER TABLE GR17_ALQUILER ADD CONSTRAINT CHK_GR17_ALQUILER_CONSISTENTE_FECHA CHECK (
    to_char(fecha_desde, 'YYYY-MM-DD') <= to_char(fecha_hasta, 'YYYY-MM-DD')
    OR fecha_desde IS NULL
);

-- Control de tipos posibles de posicion 
ALTER TABLE GR17_POSICION ADD CONSTRAINT CHK_GR17_POSICION_TIPO CHECK (
    tipo IN ('general', 'vidrio', 'insecticidas', 'inflamable');
);

