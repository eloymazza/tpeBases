<?php
    function home(){
        echo '<!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <meta http-equiv="X-UA-Compatible" content="ie=edge">
                <title>TPE BASES GR17</title>
            </head>
            <body>
                <h1>TP BASES</h1>
                <h2>Obtener posiciones libres</h2>
                <form action="posicionesLibres.php" method="post">
                    <input type="text" placeholder="Ingrese Fecha" name="fecha">
                    <input type="submit" value="Enviar">
                </form>
            </body>
        </html>';
    }
?>