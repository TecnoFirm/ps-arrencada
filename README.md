
# PS-ARRENCADA

Guions/programes `Powershell` que agilitzen la configuració inicial d'ordinadors "Windows".

## Taula de continguts

0. [Accés via Invoke-WebRequest](#acces-remot)
1. [Eliminar Apps Pre-Establertes](#del-pre-apps)
2. [Actualitzar Windows](#actualitzacio)
3. [Configuracions bàsiques](#basic-config)

<a name="acces-remot"/>

## Accés al programa de manera remota

Una possibilitat a l'hora de córrer un programa seria transportar-lo en un llapis de
memòria PEN. Quan es necessiti configurar una màquina s'hauria d'inserir el llapis al
port USB i copiar els arxius `Powershell`.

Alternativament, es pot penjar al web i descarregar-lo des d'allí. Github ens permet
disposar dels arxius en línia i descarregar-los ràpidament des de qualsevol
ordinador, de forma remota.

`Powershell` és capaç de "parsejar" o llegir una pàgina web de text simple a través
de la comanda `IWR` (Invoke-WebRequest). L'adreça que apunta al repositori de
Tecnofirm és <raw.github.com/tecnofirm/ps-arrencada/main/${nom-guio}>, on
`${nom-guio}` s'ha de substituir pel nom de l'arxiu que apareix al repositori (per
exemple, `guio-conf.ps1`).

```powershell
# iwr (invoke web-request)
iwr raw.github.com/tecnofirm/ps-arrencada/main/${nom-guio} -UseBasicParsing
# Imprimeix el contingut de la pàgina a la terminal
(iwr raw.github.com/tecnofirm/ps-arrencada/main/${nom-guio} -UseBasicParsing).Content
```

A continuació es pot encadenar la lectura `IWR` amb la ordre `IEX`
(Invoke-Expression) per tal d'executar el programa.

```powershell
# Un cop s'ha llegit el guió, executa'l mitjançant iex
iwr raw.github.com/tecnofirm/ps-arrencada/main/${nom-guio} -UseBasicParsing | iex
```

<a name="del-pre-apps"/>

## Eliminar Aplicacions Preestablertes

Fragments de guions `Powershell` que desinstal·len aplicacions preinstal·lades
pel Windows, siguin "sponsors" o siguin "bloatware".

### 1. AppxPackage

Els "AppxPackage" solen ser paquets amb software del sistema, com per exemple,
la calculadora predetermindada de windows, o l'aplicació de *"bing weather"*, o
*"Cortana"*, etc. A continuació, comandes bàsiques per manipular-los:

```powershell 
# imprimeix els paquets 
Get-AppxPackage  

# filtrar pel nom '*bingnews*' 
Get-AppxPackage -Name *bingnews*  

# opció nivell de sistema (tots els usuaris)
# imprimeix tant sols el nom dels paquets.  
Get-AppxPackage -AllUsers|select name

# eliminar algun paquet de la llista 
# sembla no poder-se emprar en mode "-allusers"??
Get-AppxPackage -Name *bingnews*|Remove-AppxPackage
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
direcció o camí del desinstal·lador per a aquell programa. Un cop obtens aquesta
direcció, has de cercar per la xarxa alguna manera de córrer la comanda
de manera silenciosa. Es poden trobar exemples al començament del guió 
`guio-elap.ps1` per a *"HP Documentation"*, *"WebAdvisor by McAfee"*, etc. 

### 2. Alternatives a Get-Package

#### Windows Management Instrumentation (WMI)

Aconsegueix "informació de les classes disponibles". La comanda antiquada seria
`Get-WmiObject`; a partir de *powershell 3.0* ha sigut substituïda per
`Get-CimInstance`. No sol funcionar per software preinstal·lat. Fins i tot
sembla tenir mala reputació [^win32p-bn] [^win32p-so]. 

[^win32p-bn]: <https://sdmsoftware.com/wmi/why-win32_product-is-bad-news/>
[^win32p-so]: <https://stackoverflow.com/questions/66978090/get-wmiobject-uninstall-vs-get-ciminstance-uninstall>

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
fer a nivell de "powershell" amb el mòdul `PSWindowsUpdate` [^SoftZone]. No sembla funcionar
de manera consistent. Pel nostre cas, considerem que l'actualització manual és més
fàcil i eficient que implementar una solució automatitzada.

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

[^SoftZone]: <https://www.softzone.es/windows/como-se-hace/actualizar-windows-cmd-powershell/>

Una altra manera seria a partir de `cmd` [^Itechtics]:

```cmd
wuauclt /detectnow /updatenow
```

[^Itechtics]: <https://www.itechtics.com/run-windows-update-cmd/>

<a name="basic-config"/>

## Configuracions bàsiques

És possible configurar moltes opcions per a personalitzar l'experiència de l'usuari.
Una part important dels canvis a fer es poden automatitzar. Malgrat tot,
l'automatització demana una gran inversió de temps lliure per part del programador.
D'aquesta manera, alguns canvis es continuaràn fent manualment.

A continuació s'intenta fer una descripció d'algunes configuracions que es poden automatitzar.

### Política d'execució de guions PowerShell

Permetre l'execució de guions `Powershell`. Pot arribar a ser un important forat de
seguretat. Es recomana **NO** canviar la configuració restringida.

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

Cada ordinador de la xarxa local s'identifica segons un *"ComputerDNS"* únic. No
poden existir *"ComputerDNS"* duplicats dins una mateixa xarxa local o no podràn
navegar per la xarxa correctament.

```powershell
Rename-Computer -NewName "$new_computer_dns"
```

És possible associar un *"Workgroup"* o grup de treball als ordinadors. En el nostre
cas utilitzarem un únic grup de treball per a totes les màquines, que serà **"TEVI"**
(TEresianes de VIlanova).

```powershell
Add-Computer -WorkGroupName "TEVI"
```

Es poden canviar els noms d'usuari locals o afegir-ne de nous [^localaccounts].

```powershell
# Llista dels usuaris actuals
Get-LocalUser
# Canvia el nom de l'usuari (usuari NAS!)
Rename-LocalUser -Name "$old_username" -NewName "$new_username"
# Canvia el nom complet de l'usuari (el que es representa a les interfícies). A més a
# més, canvia'n la contrasenya segons input manual. Els accents (`) permeten escriure
# la comanda en múltiples línies, facilitant-ne la lectura.
Set-LocalUser -Name "$user" `
    -FullName "$nom_interficies" `
    -Password $(Read-Host -AsSecureString)
# A continuació s'haurà d'introduir la contrasenya i prèmer "Intro".

### Paràgraf complex: ###
# llegeix el llistat d'usuaris i troba quins d'ells estàn activats (al llistat hi
# poden sortir usuaris inhabilitats). Guarda-ho a la variable "$LocUsr".
Get-LocalUser | Where {$_.Enabled -eq 1} |% {$LocUsr = $_.Name}
# Permet escriure a la terminal una cadena de text. Es guarda a la variable $NewUsr.
$NewUsr = Read-Host -Prompt "Write the new LocalUser name"
# Canvia el nom de l'usuari segons l'input manual que s'hagi donat...
Rename-LocalUser -Name $LocUsr -NewName $NewUsr

# Crea un nou usuari i elimina l'anterior:
$NewUsr = Read-Host -Prompt "Write the new LocalUser name"
# Crea una nova compta.
New-LocalUser -FullName "$nom_interficies" -Name "$user" -NoPassword -Description "Description of this account"
# Elimina usuaris antics o obsolets.
Remove-LocalUser -Name "tmp"
```

[^localaccounts]: <https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/new-localuser?view=powershell-5.1>

És possible que el Powershell no inclogui als nous usuaris dins de cap grup, de
manera que no es puguin veure fora de `Get-LocalUsers`. Donarien la sensació de ser
comptes desactivats. Si aquest és el cas, revisar
[enllaç](<https://stackoverflow.com/questions/39612807/local-user-account-created-with-powershell-is-not-shown-in-settings-family-ot>).
S'hauràn d'afegir els nous usuaris a un grup ("Usuarios" o "Administradores").

```powershell
# Afegir nous usuaris a un grup
Add-LocalGroupMember -Group "Administradores" -Member "$user"
```

### Canvia quanta estona triga a entrar en repós

La funció `Powercfg` permet configurar el temps inactiu que deixa passar l'ordinador
abans d'entrar en repós. La primera paraula de la sub-funció especifica repós de monitor
o d'ordinador. La segona part descriu, pels portàtils, diferents quantitats de temps
segons si està endollat (ac) o desendollat (dc).

```powershell
Powercfg /Change monitor-timeout-ac 4
Powercfg /Change monitor-timeout-dc 10
Powercfg /Change standby-timeout-ac 10
Powercfg /Change standby-timeout-dc 20
```

Es poden trobar instruccions executant `Powercfg /?`

