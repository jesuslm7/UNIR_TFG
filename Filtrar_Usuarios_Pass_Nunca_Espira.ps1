#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     López Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#

# Importamos el módulo de directorio activo
import-module Activedirectory

# Filtramos los usuarios que tienen en su configuracón
# que la contraseña nunca le espira.
Get-ADUser -filter * -properties name, emailaddress, passwordneverexpires   | where {$_.passwordneverexpires -eq "true"}  | Select samaccountname,Name,emailaddress | Sort-Object -Property name  | Format-Table
