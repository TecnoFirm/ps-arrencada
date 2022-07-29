# Automatitzar Windows Update

És perillós, recordem que descarreguem contingut de manera automatitzada.

```powershell
# Instal·lar mòdul WinUp
Install-Module PSWindowsUpdate

# Carregar una llista d'actualitzacions:
Get-WindowsUpdate

# Mostrar llista de comandes disponibles:
Get-Command -Module PSWindowsUpdate

# Eliminem restriccions de descàrrega d'scripts ps1:
Get-ExecutionPolicy
# Si la política = Restricted:
Set-ExecutionPolicy Unrestricted

# Instal·lar totes les actualz. trobades:
Get-WindowsUpdate -AcceptAll -Install -AutoReboot
```

[Ref1](https://www.softzone.es/windows/como-se-hace/actualizar-windows-cmd-powershell/)
