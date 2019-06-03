<?php
    echo '<!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <meta http-equiv="X-UA-Compatible" content="ie=edge">
            <link rel="stylesheet" href="css/main.css">
            <title>TPE BASES GR17</title>
        </head>
        <body>
            <h1>TP BASES</h1>
            <h2>Obtener posiciones libres</h2>
            <form action="posicionesLibres.php" method="post">
                <input type="text" placeholder="Ingrese Fecha" name="fecha">
                <input type="submit" value="Enviar">
            </form>
            <h2>Obtener Alquileres por vencer</h2>
            <form action="vencimientoAlquiler.php" method="post">
                <input type="number" placeholder="Ingrese Cantidad de dias" name="dias">
                <input type="submit" value="Enviar">
            </form>
        </body>
    </html>'
?>


