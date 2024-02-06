#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Obtenemos todos los scopes que hay en el servidor DHCP
# Obtenemos todas las concesiones en el servidor DHCP
# Lo exportamos a un archivo CSV
Get-DhcpServerv4Scope -ComputerName "dc-unir.unir.msft" | Get-DhcpServerv4Lease -ComputerName "dc-unir.unir.msft" | Export-Csv "concesiones.csv" -Delimiter ";"