<?php
    include_once('dbConnection.php');
    include_once('templates/posicionesLibres.php');
    function getPosicionesLibres(){
        global $db;
        $fecha = "'".$_POST["fecha"]."'";
        $query = $db->prepare("SELECT * FROM getPosicionesLibres('2001-01-01')");
        $query->execute();
        $posLibres = $query->fetchAll(PDO::FETCH_ASSOC);
        if(sizeOf($posLibres) == 0){
            echo "No hay posiciones libres para la fecha dada.";
        }
        else{
            posicionesLibresView($posLibres);         
        }

    }

    getPosicionesLibres();
 
?>