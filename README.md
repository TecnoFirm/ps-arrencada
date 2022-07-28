# ps-arrencada

Guions "powershell" que agilitzen la configuració inicial d'ordinadors "Windows".

## primera: appxpackage

Solen ser paquets de sistema, com per exemple, la calculadora predetermindada de windows, o l'aplicació de "bing weather",
o cortana...

```powershell
# cmdlet bàsic
Get-AppxPackage  

# filtrar per noms
Get-AppxPackage -Name *bingnews*  

# nivell de sistema (tots els usuaris)
# imprimeix tant sols el nom dels paquets. 
Get-AppxPackage -AllUsers|select name
```
