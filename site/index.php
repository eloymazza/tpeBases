<?php
    echo '
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" type="text/css" href="css/bootstrap.css">
        <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css">
        <link rel="stylesheet" type="text/css" href="css/style.css">
        <title>TP BASES - GR17</title>
    </head>
    <body>
    
        <section>
            <div class="container">
                <div class="wrapper">
                    <div class="row">
                        <div class="text-center col-md-12"> 
                            <div class="feature-box">
                                <h1>WMS Tandil</h1>
                                <div>
                                    <br>
                                    <h4>Obtener posiciones libres</h4>
                                    <form class="form-group col-md-4 col-md-offset-4" action="posicionesLibres.php" method="post">
                                      <div>
                                        <input class="form-control" type="text" placeholder="Ingrese Fecha" name="fecha">
                                        <br>
                                        <input class="btn btn-primary" type="submit" value="Enviar">
                                    </form>
                                    <br>
                                    <br>
                                    <br>
                                    <h4>Obtener Alquileres por vencer</h4>
                                    <form class="form-group col-md-12" action="vencimientoAlquiler.php" method="post">
                                        <input class="form-control" type="number" placeholder="Ingrese Cantidad de dias" name="dias">
                                        <br>
                                        <input class="btn btn-primary" type="submit" value="Enviar">
                                    </form>
                                </div>
                            </div> 
    
                            <div class="row">
                                <div class="col-md-12">
                                    <img id="image-server" src="css/images/sv.png">
                                </div>
                            </div>  
                        </div>
                    </div> 
                </section>
    
                <footer><p class="text-center">Trabajo Practico Especial - Grupo 17 (Mazza Eloy, Segura Emanuel)</p></footer>  
            </div>
    
            <img id="image-box" src="images/box.svg">
            <script type="text/javascript" src="js/bootstrap.js"></script>
            <script type="text/javascript" src="js/jquery-3.3.1.js"></script>
        </body>
        </html>
    
    '
?>


