# PS-ARRENCADA

Guions "powershell" que agilitzen la configuració inicial d'ordinadors "Windows".

## Taula de Continguts

1. [Eliminar Apps Pre-Establertes](#del-pre-apps)
2. [Actualitzar Windows](#actualitzacio)
3. [Configuracions bàsiques](#basic-config)

<a name="del-pre-apps"/>

## Eliminar Aplicacions Pre-Establertes

Fragments de guions *powershell* que desinstal·len aplicacions pre-establertes
per Windows, tant sponsors com bloatware.

### 1. AppxPackage

Els "AppxPackage" solen ser paquets amb software del sistema, com per exemple,
la calculadora predetermindada de windows, o l'aplicació de *"bing weather"*, o
*"Cortana"*, etc. A continuació, comandes bàsiques per manipular-los:

```powershell 
# imprimeix els paquets 
Get-AppxPackage  

# filtrar pel nom '*bingnews*' 
Get-AppxPackage -Name *bingnews*  

# opció nivell de sistema (tots els usuaris) # imprimeix tant sols el nom dels paquets.  
Get-AppxPackage -AllUsers|select name

# eliminar algun paquet de la llista 
Get-AppxPackage -Name *bingnews*|Remove-AppxPackage # sembla no poder-se emprar en mode "-allusers"
```

La opció `-AllUsers` no sembla funcionar correctament; per exemple, no sembla
deixar desinstal·lar BingNews a nivell de sistema. 

Una alternativa, també trencada:

```powershell
# des de 2019 no funciona?
Get-Package *notepad*|Uninstall-Package

# alternativa alterant alternada...?
Get-Package *notepad*|% { & $_.Meta.Attributes["UninstallString"]}
```

Per aplicacions difícils de desinstal·lar, còrrer la comanda
`Get-Package *mcafee*|% { $UNI = $_.Meta.Attributes["UninstallString"]}`.

Amb ella aconsegueixes la variable `$UNI`, que seria una cadena amb la
direcció del desinstal·lador per a aquell programa. Un cop obtens aquesta
direcció, has de cercar per la xarxa alguna manera de córrer la comanda
de manera silenciosa. Es poden trobar exemples al començament del guió 
`guio-elap.ps1` per a *"HP Documentation"*, *"WebAdvisor by McAfee"*, etc. 

### 2. Alternatives a Get-Package

#### Windows Management Instrumentation (WMI)

Aconsegueix "informació de les classes disponibles". La comanda antiquada seria
`Get-WmiObject`; a partir de *powershell 3.0* ha sigut substituïda per
`Get-CimInstance`. No sol funcionar per software preinstal·lat. Fins i tot
sembla tenir mala reputació [<sup>1</sup>][win32p-bn] [<sup>2</sup>][win32p-so]. 

[win32p-bn]: <https://sdmsoftware.com/wmi/why-win32_product-is-bad-news/>
[win32p-so]: <https://stackoverflow.com/questions/66978090/get-wmiobject-uninstall-vs-get-ciminstance-uninstall>

```powershell 
# imprimeix els paquets 
Get-CimInstance -Class Win32_Product|select name (Get-CimClass Win32_Product).CimClassMethods
```

#### Get-ChildItem

```powershell 
# HKLM: Local Machine (~all users)
# HKCU: Current User
$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
foreach($obj in $InstalledSoftware){write-host $obj.GetValue('DisplayName') -NoNewline; 
write-host " - " -NoNewline; write-host $obj.GetValue('DisplayVersion')}

# per eliminar, provar (recurse opcional; per directoris?)...
Get-ChildItem -Recurse|Remove-Item
```

<a name="actualitzacio"/>

## Automatitzar Windows Update

És perillós, recordem que descarreguem contingut de manera automatitzada. Es pot
fer a nivell de "powershell" amb el mòdul `PSWindowsUpdate`. No sembla funcionar
de manera consistent. 

```powershell
# Instal·lar mòdul WinUp (es recomana afegir -Force)
Install-Module PSWindowsUpdate

# Carregar/Visualitzar una llista d'actualitzacions:
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

REF: [SoftZone](https://www.softzone.es/windows/como-se-hace/actualizar-windows-cmd-powershell/)

Una altra manera seria a partir del cmd:

```cmd
wuauclt /detectnow /updatenow
```

REF: [Itechtics](https://www.itechtics.com/run-windows-update-cmd/)

<a name="basic-config"/>

## Configuracions bàsiques

És possible configurar moltes opcions per a personalitzar l'experiència de l'usuari.
A continuació s'intenta fer una descripció d'algunes configuracions que es poden automatitzar.

### Política d'execució de guions PowerShell

Es pot modificar al començament i al final del procés automàtic, perquè PowerShell
es pugui executar sense cap error.

```powershell
# Elimina restriccions.
if ((Get-ExecutionPolicy) -eq "Restricted") {
    Set-ExecutionPolicy "Unrestricted"
}

# Re-defineix; torna a restringir.
if ((Get-ExecutionPolicy) -eq "Unrestricted") {
    Set-ExecutionPolicy "Restricted"
}
```

### Canviar el nom de l'equip i usuari local

No es recomana canviar el nom de l'usuari local, ja que tot i fer-ho continua
quedant registrat el primer nom de qui va crear el compte. Millor crear un
nou compte amb un nou nom, i eliminar el compte primigeni. 

```powershell
# Qui és l'user actual, i qui serà el nou usr?
Get-LocalUser | Where {$_.Enabled -eq 1} |% {$LocUsr = $_.Name}
$NewUsr = Read-Host -Prompt "Write the new LocalUser name"
# Canvia-li el nom segons input manual...
Rename-LocalUser -Name $LocUsr -NewName $NewUsr

# Crea un nou usuari i elimina l'anterior:
$NewUsr = Read-Host -Prompt "Write the new LocalUser name"
# Crea la nova compta
New-LocalUser -FullName "Adria Copa de Vi de Veritat" -Name "Adria" -NoPassword -Description "Description of this account"
# Elimina l'anterior
Remove-LocalUser -Name "tmp"

# Canvia el nom del "workgroup" i de l'equip:
Add-Computer -WorkGroupName "TEVI"  # CsDomain
$CsDNS = Read-Host -Prompt "Write the new ComputerDNS name"
Rename-Computer -NewName $CsDNS
```

REF: [Windows Docs](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/new-localuser?view=powershell-5.1)

### Canvia quanta estona triga a entrar en repós

La funció és `Powercfg`. La primera paraula de la sub-funció separa repós de monitor i d'ordinador. 
La segona part (ac/dc) descriu, pels portàtils, temps si esta endollat (ac) o temps si esta desendollat (dc). 

```powershell
Powercfg /Change monitor-timeout-ac 4
Powercfg /Change monitor-timeout-dc 10
Powercfg /Change standby-timeout-ac 10
Powercfg /Change standby-timeout-dc 20
```
