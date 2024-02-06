#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Importarmos la librería necesaria para trabajar con el servidro DNS
import-module dnsserver

# Obtenemos las distintas zonas dnsn para el servidor del 
# que deseemos obtener los registros. 
$zonas = Get-DnsServerZone -ComputerName "192.168.51.141"
$csv_salida = "registro_dns.csv"

# Creamos una variable de datos estructurados para poder obtener todos los registros
# que componen cada zona DNS. Como luego los exportaremos, como primera línea pondremos 
# la cabecera de la información a exportar.
$salida = [pscustomobject]@{ 
				nombre_zona = "Nombre de la zona"
				nombre = "Nombre del registro"
				tipo_registro = "Tipo registro"
				direccion_ip = "Direccion IP"
}

# Recorremos cada una de las zonas para obtener los distintos 
# registros
foreach ($zona in $zonas)
	{
	# Obtenemos todos los registros de la zona
	$registros = Get-DnsServerResourceRecord $zona.zonename
	
	# Recorremos los registros de la zona para ir obteniendolos 
	# Añadiremos los valores a la variable estructurada
	foreach ($registro in $registros)
		{
			$salida= @($salida) +  [pscustomobject]@{ 
				nombre_zona = $zona.zonename
				nombre = $registro.hostname
				tipo_registro = $registro.recordtype
				direccion_ip = $registro.RecordData.IPv4Address.IPAddressToString
			}
		}
	}

# Exportamos los datos a un csv y ponemos como delimitador ; 
# para que Excel automáticamente lo separe en columnas
$salida | Export-Csv "registro_dns.csv" -Delimiter ";" -NoTypeInformation

# Abrimos el fichero
Invoke-Item $csv_salida