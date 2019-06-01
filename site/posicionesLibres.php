<?php
    function getPosicionesLibres(){
        $fecha = "'".$_POST["fecha"]."'";
        $selectPosLibres = (
            "SELECT nro_posicion, nro_estanteria, nro_fila
             FROM GR17_ALQUILER_POSICIONES ap
             WHERE id_alquiler IN (
                SELECT id_alquiler 
                FROM GR17_ALQUILER
                WHERE fecha_desde < $fecha AND fecha_hasta > $fecha
                )"
        );
        echo $selectPosLibres;

        $db = new PDO("pgsql:host=dbases.exa.unicen.edu.ar; port=6432; user=unc_248849; dbname=cursada; password=altairezzio1");
        $query = $db->prepare($selectPosLibres);
        $query->execute();
        $result = $query->fetchAll();
        print_r($result);
    }

    getPosicionesLibres();
 
?>