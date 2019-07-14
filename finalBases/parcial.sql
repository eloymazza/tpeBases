CREATE VIEW ALQUILERES_MAS_MOVIMIENTOS AS
SELECT id_alquiler, COUNT(*)
FROM GR17_MOV_ENTRADA me INNER JOIN GR17_MOVIMIENTO m ON m.id_movimiento=me.id_movimiento
WHERE m.fecha > CURRENT_DATE - interval '6 month'
GROUP BY id_alquiler
ORDER BY COUNT(*) desc
LIMIT 5

SELECT nro_fila, nro_posicion, nro_estanteria, COUNT(*)
FROM GR17_ALQUILER_POSICIONES ap INNER JOIN GR17_ALQUILER a ON ap.id_alquiler=a.id_alquiler 
WHERE fecha_hasta > CURRENT_DATE - 130 
GROUP BY nro_fila, nro_posicion, nro_estanteria
ORDER BY 4 desc
LIMIT 1