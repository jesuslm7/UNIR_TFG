#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Definimos el nombre del servidor DHCP
$servidor_dhcp = "dc-unir.unir.msft"

# Definimos el ambito origen y el ámbito destino en el cual vamos a introducir 
# las reservas de del ámbito origen cambiando la IP.
$ambito_origen=  "192.168.51.0"
$rango_origen = ".51."
$ambito_destino= "192.168.60.0"
$rango_destino = ".60."

try
	{
		Add-DhcpServerv4Scope -Name "Equipos de Unir - Madrid" -Description "IPs de Madrid" -StartRange 192.168.60.2 -EndRange 192.168.60.150 -SubnetMask 255.255.255.0 
	}
catch
	{
		write-warning "Error al crear el Ambito"
	}

# Exportamos las reservas a un fichero CSV para luego poder importarlas. 
$reservas_orgigen = Get-DhcpServerv4Reservation -ComputerName $servidor_dhcp -ScopeId $ambito_origen | Export-Csv "Exportar_Reserva.csv" -NoTypeInformation -Delimiter ";"

# Importamos las reservas que hemos exportado del ambito origen
$reservas_destino=import-Csv "Exportar_Reserva.csv" -Delimiter ";"

ForEach ($reserva in $reservas_destino)
	{   
		# Semaforo para capturar error al obtener una reserva en el DHCP
		$existe = $false
		Try
			{	# El cmdlet Get-DhcpServerv4Reservation si no lo obtiene da un error y continua la ejecución por lo que no se puede
				# tratar capturando la excepcion, para ello es necesario añadir -ErrorAction Stop y asi podemos captura la excepción. 
				$res = Get-DhcpServerv4Reservation -ComputerName $servidor_dhcp -ScopeId $ambito_destino -ClientId $reserva.ClientId -ErrorAction Stop
			}
		catch
			{ 
				$existe = $true
			}

	#if (($existe.Name -ne $null) -or ($existe))
	if 	($existe)
			{
	# Reemplazamos la dirección IP para que esté en el nuevo ámbito
	$IP= $reserva.IPAddress -replace $rango_origen, $rango_destino
	
	# Añadimos la reserva con la nueva IP en el nuevo ámbito.
	Add-DhcpServerv4Reservation -ComputerName $servidor_dhcp -ScopeId $ambito_destino -Name $reserva.Name -IPAddress $IP -ClientId $reserva.ClientID -Description $reserva.Description
	
	# Eliminamos la reserva del ámbito origen
	Remove-DhcpServerv4Reservation -ComputerName $servidor_dhcp  -ScopeId $ambito_origen -ClientId $reserva.ClientID
	$existe = $false
			}
	else 
			{
				# La reserva existe e indicamos que no la creamos porque ya existe.
				 Write-Warning "Existe la sererva DHCP en el Ambito: "  
				 write-host $ambito_destino
				 Write-host $reserva.Name  $reserva.ClientID
			}
}
