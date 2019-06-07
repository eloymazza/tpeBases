<?php
    function posicionesLibresView($posLibres){
        echo "      
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset='utf-8'>
            <meta name='viewport' content='width=device-width, initial-scale=1.0'>
            <link rel='stylesheet' type='text/css' href='css/bootstrap.css'>
            <link rel='stylesheet' type='text/css' href='css/bootstrap.min.css'>
            <link rel='stylesheet' type='text/css' href='css/style.css'>
            <title>TP BASES - GR17</title>
        </head>
        <body>
            <section>
                <div class='container'>
                <a href='index.php'> Home
                    <div class='wrapper'>
                        <div class='row'>
                            <div class='text-center col-md-12'> 
                                <div class='feature-box'>
                                    <h1>WMS Tandil</h1>
                                    <div>
                                        <br>
                                        <div>
                                            <div>
            <h2>Posiciones Libres</h2>
        <table class='table'>
          <thead>
            <tr>
              <th scope='col'>Nro Posicion</th>
              <th scope='col'>Nro Estanteria</th>
              <th scope='col'>Nro Fila</th>
            </tr>
          </thead>
          <tbody>";
        foreach ($posLibres as $posicion){
            echo "
                <tr>
                    <td>$posicion[nro_posicion]</td>
                    <td>$posicion[nro_estanteria]</td>
                    <td>$posicion[nro_fila]</td>
                </tr>
            ";
        }
        echo "
            </tbody>
                </table>
                    <div class='row'>
                        <div class='col-md-12'>
                            <img id='image-server' src='css/images/sv.png'>
                        </div>
                    </div>  
                </div>
             </div> 
            </section>
                <footer><p class='text-center'>Trabajo Practico Especial - Grupo 17 (Mazza Eloy, Segura Emanuel)</p></footer>  
            </div>
            <img id='image-box' src='css/images/box.svg'>
            <script type='text/javascript' src='js/bootstrap.js'></script>
            <script type='text/javascript' src='js/jquery-3.3.1.js'></script>
        </body>
        </html>
        ";
    };
?>