#----------------------------------------------------------------------#
#| Nombre    Apellido           	Asignatura		     	UNIVERSIDAD|
#|---------------------------------------------------------------------|
#| Jesús     Loóez Márquez         	TFG                          UNIR  |
#----------------------------------------------------------------------#
Rename-Computer -NewName DC-UNIR -Restart
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools 
Install-ADDSForest -DomainName "unir.msft" -SafeModeAdministratorPassword (Convertto-SecureString -AsPlainText "Unir.2024" -Force) -InstallDNS