#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Definimos el nombre del servidor DHCP
$servidor_dhcp = "dc-unir.unir.msft"

# Definimos el ambito en el cual vamos a introducir las nuevas reservas
$ambito = "192.168.51.0"

# Importamos la lista de reservas que vamos a importar. Usamos el ";"
# como delimitador. 
$reservas = Import-Csv "reservas.csv" -Delimiter ";"

# Semaforo para capturar error al obtener una reserva en el DHCP


# Recorremos la lista de reservas a importar
foreach ($reserva in $reservas)
	{	$noexiste = $false
		# Concatenamos el nobmre de la reserva para añadir la reserva.
		$nombre = $reserva.Nombre + "unir.msft"

		# Para comprobar si la reserva existe, intentamos obtenerlo
		try
			{	# El cmdlet Get-DhcpServerv4Reservation si no lo obtiene da un error y continua la ejecución por lo que no se puede
				# tratar capturando la excepcion, para ello es necesario añadir -ErrorAction Stop y asi podemos captura la excepción. 
				$existe = Get-DhcpServerv4Reservation -ComputerName $servidor_dhcp -ScopeId $ambito -ClientId $reserva.Cliente -ErrorAction Stop
			}
		catch
			{ 
				$noexiste = $true 
			}

		# Si el nombre de la reserva obtenida no es nulo, significa que no existe y podemos crear la reserva
		if (($existe.nombre -ne $null) -or ($noexiste))
			{
				# La reserva no existe y la creamos.
				Add-DhcpServerv4Reservation -ScopeId $ambito -Name $nombre -IPAddress $reserva.IP -ClientId $reserva.Cliente -Description $reserva.Descripcion
				$noexiste = $false
			}
		else 
			{
				# La reserva existe e indicamos que no la creamos porque ya existe.
				 Write-Warning "Existe la sererva DHCP: "  
				 Write-host $reserva.Nombre  $reserva.IP
			}
	}