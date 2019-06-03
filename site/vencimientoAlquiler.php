<?php
    include_once('dbConnection.php');
    function getClientesANotificar(){
        global $db;
        $dias = $_POST["dias"];
        $selectClientes = (
            "SELECT *
            FROM GR17_CLIENTE c
            JOIN GR17_ALQUILER a ON (a.id_cliente = c.cuit_cuil)
            WHERE fecha_hasta - $dias = CURRENT_DATE"
        );
             
        $query = $db->prepare($selectClientes);
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
                <p>Fecha Alta: $cliente[fecha_alta] </p>
                <p>ID Alquiler:$cliente[id_alquiler]  </p>
                <p>ID Cliente: $cliente[id_cliente] </p>
                <p>ID Fecha Desde: $cliente[fecha_desde] </p>
                <p>ID Fecha Hasta: $cliente[fecha_hasta] </p>
                <p>ID Importe Dia: $cliente[importe_dia]$ </p> ";
            }
        }
        echo "<a href='index.php'> Home";
       
    }

    getClientesANotificar();
 
?>

