#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Introducimos el nombre del servidor DNS
$servidor_dns = 'dc-unir'; 

# Introducimos la zona directa en la que comprobaremos que todos los registro A:
# Dispongan de su correspondiente registro PTR.
$zona_directa = "unir.msft";

# Introducimos la zona inversa.
$zona_inversa = "51.168.192.in-addr.arpa"

# Obtenemos todos los registros DNS
$registros = Get-DnsServerResourceRecord -ZoneName $zona_directa -RRType A -ComputerName $servidor_dns; 
foreach ($registro in $registros) 
{ 
    # Obtenemos el nombre del que es el registro A para poder obtener la dirección IP
	# Y asi poder crear el registro PTR asociado al registro A.
    $nombre_registro = $registro.HostName + "." + $zona_directa; 

    # Reverse the IP Address for the name record.
    $name = ($registro.RecordData.IPv4Address.ToString() -replace '^(\d+)\.(\d+)\.(\d+).(\d+)$','$4.$3.$2');
	$octeto = $name.split(".")[0]
    
	# Añadimos el registro PTR solo si existe por lo que intentaremos obtenerlo y si no existe, lo creamos.
	$registro_ptr = Get-DnsServerResourceRecord -ZoneName "51.168.192.in-addr.arpa" -Name $octeto -RRType Ptr -ErrorAction SilentlyContinue  
	
	# Si no existe el registro PTR asociado al registro A lo creamos.
	if ($registro_ptr -eq $null)
		{
			# Creamos el registro PTR. 
			Add-DnsServerResourceRecordPtr -Name $octeto -ZoneName "51.168.192.in-addr.arpa" -ComputerName $servidor_dns -PtrDomainName $nombre_registro; 
		}
}