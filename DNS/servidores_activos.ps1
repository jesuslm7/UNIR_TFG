#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Leemos el archivo de texto con los nombres DNS 
# de los servidores que deseamos verificar que estén activos.
$fichero_servidores = ".\lista_servidores.txt"
$nombre_excel = "servidores_activos.xlsx"

if (Test-Path ($fichero_servidores) )
{
	# Si el de texto con los datos existe importamos los nombres de los esrvidores. 
	 $servidores = get-content  $fichero_servidores


	# Generamos el objeto Excel para generar un archivo excel con la salida.
	$excel = New-Object -ComObject excel.application
	# Creamos un libro de trabajo por defecto la primera vez son 3 hojas.
	$workbook = $excel.Workbooks.Add()
	# En resultado lo pondemores en la primera hoja del libro
	# por eso usamos ItemM(1).
	$resultado= $workbook.Worksheets.Item(1)
	# Le pondemos nombre a la primera hoja del Excel donde pondremos
	# los resultados.
	$resultado.Name = 'Servidores Activos'

	# Le damos formato a la parte superior donde irá un texto descriptivo
	# de lo que contendrá el fichero Excel, en este caso Servidores activos - ms
	$resultado.Cells.Item(1,1).Font.Size = 18
	$resultado.Cells.Item(1,1).Font.Bold=$True
	$resultado.Cells.Item(1,1).Font.Name = "Cambria"
	$resultado.Cells.Item(1,1).Font.ThemeFont = 1
	$resultado.Cells.Item(1,1).Font.ThemeColor = 4
	$resultado.Cells.Item(1,1).Font.ColorIndex = 55
	$resultado.Cells.Item(1,1).Font.Color = 8210719
	$resultado.Cells.Item(1,1) = 'Servidores activos - ms'

	# Para que quede bien combinamos las celdas y visualmente
	# quede bien "Servidores activos  ms"
	$range = $resultado.Range("a1:c1")
	$range.MergeCells = $true


	# Añadimos la fecha para que quede constancia de la fecha en la que se ejecutó el script
	$resultado.Cells.Item(2,1) = 'Fecha: '
	$resultado.Cells.Item(2,2) = (Get-Date).ToString()

	# La variable i será la variable que nos indica la fila donde tendremos que introducirlo.
	# Primero vamos a generar la cabecera donde pondremos el servidor y la media en ms de respuesta
	# por parte del servidor
	$i=5
	$resultado.Cells.Item($i,1).Interior.ColorIndex =48
	$resultado.Cells.Item($i,1).Font.Bold=$True
	$resultado.Cells.Item($i,2).Interior.ColorIndex =48
	$resultado.Cells.Item($i,2).Font.Bold=$True
	$dataRange = $resultado.Range("a5:b5")
	$dataRange.Borders.LineStyle = 1
	$dataRange.Borders.Weight = 3
	$resultado.Cells.Item($i,1) = 'Servidor'
	$resultado.Cells.Item($i,2) = 'Tiempo en ms'


	# Recorremos todos los servidores que están en el archivo que hemos leido
	# lista_listaservidores.txt
	foreach ($servidor in $servidores) { 
		
		# Añadiremos el servidor y el valor medio de respuesta del servidro en la siguiente
		# fila. Convertimos el tiempo medio a entero. 
		$i=$i+1
		$test = (Test-Connection -ComputerName $servidor -Count 4 -erroraction 'silentlycontinue' | measure-Object -Property ResponseTime -Average).average 
		$response = ($test -as [int] ) 
		

		# Añadimos a la hoja de cálculo el servidor y el tiempo medio
		$resultado.Cells.Item($i,1) = $servidor
		if ($response -eq 0)
		{
			$resultado.Cells.Item($i,2) = "No disponible."
		}
		else
		{
			$resultado.Cells.Item($i,2) = $response
		}
		
		# Aplicamos el estilo para que tenga borde y grosor del borde.
		$dataRange = $resultado.Range("a$i","b$i")
		$dataRange.Borders.LineStyle = 1
		$dataRange.Borders.Weight = 2
		
	} 

	# Ajustamos las celdas al contenido.
	$usedRange = $resultado.UsedRange	
	$usedRange.EntireColumn.AutoFit() | Out-Null

	$last = $resultado.UsedRange.SpecialCells(11).Address($False,$false)

	# 
	$range1 = $resultado.range("A6:$last" )
	$range2 = $resultado.range("A5")
	$range3 = $resultado.range("B5")

	# Ordenamos por por el tiempo de respuesta y por servidor.
	$resultado.sort.sortFields.clear()
	[void]$resultado.sort.sortFields.add($range3, 0, 2)
	[void]$resultado.sort.sortFields.add($range2, 0, 2)
	$resultado.sort.setRange($range1)
	$resultado.sort.header = $xlNo
	$resultado.sort.orientation = 1
	$resultado.sort.apply()


	# Lo mostramos una vez que hemos terminado de añadir toda la información
	write-host "Fecha en la que se ha ejecutado el script: " $(get-date -f "MM-dd_yy_HH_mm_ss") 


	$excel.visible = $True
	$base = Get-Location 
	$ruta = Join-Path -Path $base -ChildPath $nombre_excel
	$workbook.saveas($ruta)
	$excel.quit()
	

}
else
{
	# El fichero de texto con los servidores no existe y no podemos importar los servidores.
	# Mostramos un mensaje por pantalla indicando que no existe el fichero con la lista de servidores.
	write-host "El fichero lista_servidores.txt no existe en la ruta del script"
}