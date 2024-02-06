#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Obtenemos los servidores DNS.
$servidores_DNS = Get-DnsClientServerAddress -AddressFamily ipv4

# Obtenemos el nombre del equipo.
$nombre_equipo = [System.Net.Dns]::GetHostName()

# Creamos una estructura de datos para almacenar las interfaces que sean
# E* haciendo referencia a las Ethernt.
$lista =[pscustomobject]@{
	interface = "Interfaces"
	dns = @("IPs")
}

# Recorremos la lista de servidores DNS de las interfaces que empiecen por E*
# para que sean todas las Ethernet. 
foreach ($dns in $servidores_DNS)
	{
		if ($dns.interfaceAlias -like "E*")
		{
				$lista = @($lista) + 
				[pscustomobject]@{
					interface=$dns.interfaceAlias 
					dns=$dns.ServerAddresses
				}
		}
	}

# Obtenemos la dirección IP.
$direccion_ip = (Get-NetIPAddress -AddressFamily IPv4 | where interfacealias -like "E*").IPAddress

# Obtenemos la puerta de enlace predeterminada. 
$puerta_enlace = ((Get-NetIPConfiguration).IPv4DefaultGateway).Nexthop

# Obtenemos el servidor DHCP. 
$servidor_dhcp = (Get-DhcpServerInDC).IPAddress.IPAddressToString

# Obtenemos el controlador de dominio donde se ha iniciado sesión, que muchas veces es un dato 
# importante para resolver problemas. 
$dc = $env:LOGONSERVER

# Sacamos por pantalla 
write-host ""
write-host "#------------------------------------------#" -ForegroundColor Green
write-host "#- Nombre, DNS, IP, Puerta enla, DHCP, DC -#" -ForegroundColor Green
write-host "#------------------------------------------#" -ForegroundColor Green
write-host "Nombre del equipo: " -ForegroundColor Green -NoNewline; write-host $nombre_equipo 
write-host "Servidores DNS: " -ForegroundColor Green -NoNewline; write-host $lista[1].dns
write-host "Direccion IP: " -ForegroundColor Green -NoNewline; write-host $direccion_ip
write-host "Puerta de Enlace: " -ForegroundColor Green -NoNewline; write-host $puerta_enlace
write-host "Servidor DHCP: " -ForegroundColor Green -NoNewline; write-host $servidor_dhcp
write-host "Iniciado sesion en DC: " -ForegroundColor Green -NoNewline; write-host $dc
write-host "#------------------------------------------#" -ForegroundColor Green

# Obtenemos modelo del equipo.
$modelo = (wmic csproduct get name)[2]

# Obtenemos serial del equipo
$serial = (wmic bios get serialnumber)[2]


# Mostramos información del equipo.
write-host ""
write-host "#------------------------------------------#" -ForegroundColor red
write-host "#-   Informacion del equipo del equipo    -#" -ForegroundColor red 
write-host "#------------------------------------------#" -ForegroundColor red
write-host "Modelo del equipo: " -ForegroundColor red -NoNewline; write-host $modelo
write-host "Numero de serie: " -ForegroundColor red -NoNewline; write-host $serial
write-host "#------------------------------------------#" -ForegroundColor red


# Obtenemos el maestrod e infraestructura, el RID y el PDC Emulator.
$maestro_IRP = Get-ADDomain | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator

# obtenemos el maestro de nombres de dominios y el maestro de esquemas.
$maestro_NE = Get-ADForest | Select-Object DomainNamingMaster, SchemaMaster

# Lo mostramos por pantalla.
write-host ""
write-host "#------------------------------------------#" -ForegroundColor yellow
write-host "#- Informacion de maestros de operaciones -#" -ForegroundColor yellow 
write-host "#------------------------------------------#" -ForegroundColor yellow
write-host "Infraestructura: " -ForegroundColor yellow -NoNewline; write-host $maestro_IRP.InfrastructureMaster
write-host "RID: " -ForegroundColor yellow -NoNewline; write-host $maestro_IRP.RIDMaster
write-host "Emulador PDC: " -ForegroundColor yellow -NoNewline; write-host $maestro_IRP.PDCEmulator
write-host "Nombres de dominio: " -ForegroundColor yellow -NoNewline; write-host $maestro_NE.DomainNamingMaster
write-host "Esquema:" -ForegroundColor yellow -NoNewline; write-host $maestro_NE.SchemaMaster
write-host "#------------------------------------------#" -ForegroundColor yellow

