<?php
    include_once('dbConnection.php');
    function getClientesANotificar(){
        global $db;
        $dias = $_POST["dias"];
        $query = $db->prepare("SELECT * FROM getClientesANotificar($dias)");
        $query->execute();
        $clientes = $query->fetchAll(PDO::FETCH_ASSOC);
        if(sizeOf($clientes) == 0){
            echo "No hay vencimientos dentro de $dias dias.";
        }
        else{
            foreach ($clientes as $cliente){
                echo "
                <p>Cuit-Cuil: $cliente[cuit_cuil]</p>
                <p>Apellido: $cliente[apellido] </p>
                <p>Nombre:$cliente[nombre] </p>
                <p>Fecha Alta: $cliente[fecha_alta] </p>";
            }
        }
        echo "<a href='index.php'> Home";
       
    }

    getClientesANotificar();
?>

