#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Primera parte del script 
# Obtenemos la fecha y la ruta base de la Unidad Organiztiva dónde vamos 
# a meter los usuarios. Inicializamos contadores para mostrar estadistica


# Obtenemos la fecha del día
$fecha = get-date -format dd_MM_yy_hh_mm_ss
$ruta_base= "OU=Gestion_UNIR,DC=unir,DC=msft"

$numero_usuarios_creados = 0
$numero_usuarios_movidos = 0
$numero_usuarios_erroneos = 0

		 
# Segunda parte del script
# Comprobamos que el CSV/EXCEL con los usuarios existe
# por defecto en la ruta dónde está el script
$fichero_usuarios = ".\Personas.csv"
if (Test-Path ($fichero_usuarios) )
{
	# Si el fichor CSV con los datos existe importamos los usuarios 
	# cambiando el separador por ";" que es el que separa los campos
	 $nuevos_usuarios = Import-Csv -Path .\Personas.csv -Delimiter ";"
	 
	# Si la Unidad Organizativa existe, muestra un mensaje por pantalla indicando que 
	# esa unidad organizativa ya existe
	 if( [adsi]::Exists("LDAP://"+"OU=Nuevos_Usuarios_"+$fecha +","+$ruta_base))
		{
		 $ruta_usuarios = "OU=Nuevos_Usuarios_"+$fecha+","+$ruta_base
		 write-host "La OU " $ruta_usuarios "existe"
		} 
	else 
		{# Si la OU no existe mostramos un mensaje indicando que no existe y la creamos
		 $Nueva_OU="Nuevos_Usuarios_"+$fecha
		 write-host "La OU" $Nueva_OU " no existe y procedemos a crearla"
		 New-ADOrganizationalUnit -DisplayName $Nueva_OU -Name $Nueva_OU -path "OU=Gestion_UNIR,DC=unir,DC=msft" -ProtectedFromAccidentalDeletion $False
		 $ruta_usuarios = "OU=Nuevos_Usuarios_"+$fecha+","+$ruta_base
		 }
	# Recorremos todos los usuarios para obtener los campos y poder añadirlos
	 foreach ($usuario in $nuevos_usuarios)
		 {
			# Añadimos estos campos, pero podríamos poder añadido otros campos
			$GivenName			   = $usuario.NOMBRE
			$Surname               = $usuario.APELLIDO1+" "+$usuario.APELLIDO2
			$Name                  = $GivenName+ " " + $Surname
			$DisplayName           = $GivenName+ " " + $Surname
			$SamAccountName        = $usuario.NOMBRE.replace(" ","") + "." + $usuario.APELLIDO1
			$UserPrincipalName     = $usuario.NOMBRE.replace(" ","") + "." + $usuario.APELLIDO1
			$Path                  = $Nueva_OU
			$Description           = $usuario.DESCRIPCION
			$Office                = $usuario.EMPRESA
			$EmailAddress          = $usuario.CORREO
			$Contrasena			   = ConvertTo-SecureString  $usuario.CONTRASENA -AsPlainText -Force
			try
			{
				New-ADUser -Name $Name  -GivenName $GivenName -Surname  $Surname -DisplayName  $DisplayName -Description $Description   -EmailAddress $EmailAddress -Office $Office -SamAccountName  $SamAccountName -UserPrincipalName $UserPrincipalName -Company $Company -path $ruta_usuarios -ChangePasswordAtLogon $true -AccountPassword $Contrasena -Enabled $true
				$numero_usuarios_creados++
			}
			catch
			{
				if ((Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'"))
				{
					# El usuario existe, lo movemos a la nueva OU
					Write-warning "Existe la cuenta: $Name - $EmailAddress" 
					Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" | Move-adobject -Targetpath $ruta_usuarios
					$numero_usuarios_movidos++
					write-host "Usuario movido a $ruta_usuarios"					
				}
				else
				{	# Existe algún problema al intentar crear al usuario
					Write-warning "Error al crear el usuario."
					$numero_usuarios_erroneos++
				}
			}
		 }
}
else
{
	# El fichero CSV no existe y no podemos importar los usuarios.
	# Mostramos un mensaje por pantalla indicando que no existe el fichero con los usuarios.
	write-host "El fichero Personas.csv no existe en la ruta del script"
}
# Mostramos estadísitca de los mensajes
Write-warning "Se han creado  $numero_usuarios_creados."
Write-warning "Se han movido  $numero_usuarios_movidos."
Write-warning "Han dado error  $numero_usuarios_erroneos "
