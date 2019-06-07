<?php
    include_once('dbConnection.php');
    include_once('templates/datosClientes.php');
    function getClientesANotificar(){
        global $db;
        $dias = $_POST["dias"];
        $query = $db->prepare("SELECT * FROM FN_GR17_getClientesANotificar($dias)");
        $query->execute();
        $clientes = $query->fetchAll(PDO::FETCH_ASSOC);
        if(sizeOf($clientes) == 0){
            echo "No hay vencimientos dentro de $dias dias.";
        }
        else{
            datosClientesView($clientes);
        }
        echo "<a href='index.php'> Home";
       
    }

    getClientesANotificar();
?>

