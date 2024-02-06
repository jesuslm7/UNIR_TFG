#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Consultar las n ultimas copias de seguridad
$n = 5

# Obteine la última que se ha ejecutado

$ultimas_ejecuciones = Get-WBJob -Previous $n | Sort-Object StartTime


# podemos poner que las siguientes copias de seguridad son
write-host "Las siguientes copias de seguridad se realizaran :" -Foreground green
# Obtenemos el listado de planes de copia que hay
# En este caso solamente habrá uno. 
$plan = Get-WBPolicy
write-host "----------------------------------------------------------" -Foreground green
Get-WBSchedule $plan
write-host "----------------------------------------------------------" -Foreground green
write-host""

# Se mostrarán las últimas n copias de seguridad y si la copia se
# realizaron de forma correcta.

# Consultaremos las últimas n copias de seguridad
$numero = $ultimas_ejecuciones.count

write-host "Estado de las copias de seguridad" -Foreground yellow
write-host "----------------------------------------------------------" -Foreground yellow
foreach ($ejecucion in $ultimas_ejecuciones)
	{
		# Obtenemos la copia n, primero se obtiene la n
		# luego la n-1, la n-2, hasta llegar a la última 
		# copia que se ha hecho la n-(n-1), la 1. 
		$copia = (Get-WBJob -Previous $n)[$n-$numero] | Sort-Object StartTime

		# Si la copia se ha realizado de forma correcta
		if ($copia.HResult -eq 0) 
			{
				write-host "La copia " $ejecucion.VersionID " se ha realizado de forma correcta"
			}
			else 
			{
				write-host "El intento de copia  el - " $copia.starttime "dio el error" $copia.ErrorDescription -Foreground red
			}
		# Pasamos a la ejecución n-1.
		$numero--
	}

write-host "----------------------------------------------------------" -Foreground yellow
