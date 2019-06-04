<?php
    include_once('dbConnection.php');
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
            foreach ($posLibres as $posicion){
                echo "<!DOCTYPE html>
                <html lang='en'>
                    <head>
                        <meta charset='UTF-8'>
                        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
                        <meta http-equiv='X-UA-Compatible' content='ie=edge'>
                        <link rel='stylesheet' href='css/main.css'>
                        <title>TPE BASES GR17</title>
                    </head>
                    <body>
                        <div class='box'>
                            <p>Nro Posicion: $posicion[nro_posicion]</p>
                            <p>Nro Estanteria: $posicion[nro_estanteria]</p>
                            <p>Nro Fila: $posicion[nro_fila] </p>
                        </div> 
                    </body>
                </html>";
            }            
        }
        echo "<a href='index.php'> Home";

    }

    getPosicionesLibres();
 
?>