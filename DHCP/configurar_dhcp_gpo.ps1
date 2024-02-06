#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Este script se habilitará a nivel de GPO de inicio de sesión para que se le configure
# de forma automática en todos los equipos el  DHCP.

# Obtenemos todas las interfaces físicas
$salida= Get-NetAdapter -Name * -Physical

# Name                      InterfaceDescription                    ifIndex Status       MacAddress             LinkSpeed
# ----                      --------------------                    ------- ------       ----------             ---------
# Ethernet0                 Intel(R) 82574L Gigabit Network Conn...      13 Up           00-0C-29-BC-E1-84         1 Gbps


# Para cada interface fisica 
$salida | foreach 
	{
		# Habilitamos para las interfaces físicas de red que obtenga la IP por DHCP
		netsh interface ip set address $_.Name dhcp
		# Habilitamos para las interfaces físicas de red que obtenga los DNS por DHCP
		netsh interface ipv4 set dnsservers $_.Name source=dhcp
	}