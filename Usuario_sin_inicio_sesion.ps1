#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Importamos el módulo de directorio activo
import-module Activedirectory

# Creamos una consulta para obtener todos los usuarios que no han iniciado sesión 
# en X tiempo. La variable días representa el número de días sin iniciar sesión desde
# la fecha en que se ejecuta el script. La variable tiempo será la fecha que se corresponde
# con restar el número de días a la fecha actual. Haremos la consulta solo sobre los usuarios 
# que se han activado y están dentro de la unidad organizativa "Gestion_UNIR" que es dónde están 
# los usuarios.
$dias = 1
$tiempo = (Get-Date).AddDays((-1)*$dias)
$usuarios = Get-ADUser -Filter {(Enabled -eq $True)} -SearchBase "OU=Gestion_UNIR,DC=unir,DC=msft" -Properties LastLogonDate | 
    Where-Object {$_.LastLogonDate -ge $tiempo} | Select-Object @{Name='Nombre';Expression={$_.Name}}, @{Name='Cuenta';Expression={$_.SamAccountName}}, @{Name='Ultimo Login';Expression={$_.LastLogonDate}}, distinguishedName

#write-host $d | Format-List


# Creamos una unidad organizativa para mover a los usuarios.
$fecha = get-date -format dd_MM_yy_hh_mm_ss
$ruta_base= "OU=Gestion_UNIR,DC=unir,DC=msft"
 if( [adsi]::Exists("LDAP://"+"OU=Usuarios_sin_iniciar_"+$fecha +","+$ruta_base))
		{
		 $ruta_usuarios = "OU=Usuarios_sin_iniciar_"+$fecha+","+$ruta_base
		 write-host "La OU " $ruta_usuarios "existe"
		} 
	else 
		{# Si la OU no existe mostramos un mensaje indicando que no existe y la creamos
		 $Nueva_OU="Usuarios_sin_iniciar_"+$fecha
		 #write-host "La OU" $Nueva_OU " no existe y procedemos a crearla para meter a los usuarios."
		 New-ADOrganizationalUnit -DisplayName $Nueva_OU -Name $Nueva_OU -path "OU=Gestion_UNIR,DC=unir,DC=msft" -ProtectedFromAccidentalDeletion $False
		 $ruta_usuarios = "OU=Usuarios_sin_iniciar_"+$fecha+","+$ruta_base
		 }

# Deshabilitamos los usuarios y los movemos los usuarios
 $numero_usuarios = 0
 foreach ($usuario in $usuarios)
	{
		try{
				Disable-ADAccount -identity $usuario.Cuenta
				Move-ADObject -Identity $usuario.distinguishedName -TargetPath $ruta_usuarios
				$numero_usuarios++
			}
		catch
			{
				write-warning "Error al desactivar y mover al usuario" $usuario.cuenta
			}
	}
			 
if ($numero_usuarios -gt 0)
	{
		write-host "Los usuarios creados son:"
		$usuarios
		write-host Numero total de usuarios creados: $numero_usuarios
	}
else 
	{
		write-host "No existen usuarios que no hayan iniciado desde " $tiempo
	}
