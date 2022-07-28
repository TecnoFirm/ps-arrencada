
# ELIMINAR APLICACIONS PRE-ESTABLERTES

Fragments de guions *powershell* que desinstal·len aplicacions
pre-establertes per Windows. 

## 1. AppxPackage

Els "AppxPackage" solen ser paquets amb software del sistema, 
com per exemple, la calculadora predetermindada de windows, 
o l'aplicació de "bing weather", o Cortana, etc. A continuació,
comandes bàsiques per manipular-los:

```powershell 
# imprimeix els paquets
Get-AppxPackage  

# filtrar pel nom '*bingnews*'
Get-AppxPackage -Name *bingnews*  

# opció nivell de sistema (tots els usuaris)
# imprimeix tant sols el nom dels paquets. 
Get-AppxPackage -AllUsers|select name

# eliminar algun paquet de la llista
Get-AppxPackage -Name *bingnews*|Remove-AppxPackage
# sembla no poder-se emprar en mode "-allusers"
```

La opció `-AllUsers` no sembla funcionar correctament; per exemple,
no sembla deixar desinstal·lar BingNews a nivell de sistema. 

## 2. Windows Management Instrumentation (WMI)

Aconsegueix "informació de les classes disponibles". La comanda antiquada
seria `Get-WmiObject`; a partir de *powershell 3.0* ha sigut
substituïda per `Get-CimInstance`. No sol funcionar per software preinstal·lat. Fins
i tot sembla tenir mala reputació [<sup>1</sup>][win32p-bn] [<sup>2</sup>][win32p-so]. 

[win32p-bn]: <https://sdmsoftware.com/wmi/why-win32_product-is-bad-news/>
[win32p-so]: <https://stackoverflow.com/questions/66978090/get-wmiobject-uninstall-vs-get-ciminstance-uninstall>
