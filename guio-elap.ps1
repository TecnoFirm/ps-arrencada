
# Preferència de verbositat: quanta informació vols veure a la terminal?
# De manera predeterminada és "SilentlyContinue", que amaga info.

# Tria: /C = Choices [Y, N]
#       /D = Default
#       /t = time-out until default
choice.exe /C yn /D y /t 15 /m "Do you want the script to be verbose? 15 secs to decide."
if ($LASTEXITCODE -eq "1") # 1 for "yes" 2 for "no"
{
$VerbosePreference = "Continue"
} else {
$VerbosePreference = "SilentlyContinue"
}

if ((Get-WinSystemLocale) -ne "ca-ES") # Si el locale NO ÉS "ca-ES";
# Pregunta si el volen canviar...
{
choice.exe /C yn /D y /t 15 /m "Do you want the locale be changed to ca-ES? 15 secs to decide."
if ($LASTEXITCODE -eq "1") # 1 for "yes" 2 for "no"
{
# Guarda la següent llista de llenguatges:
Set-WinUserLanguageList -LanguageList "ca-ES", "es-ES"
Set-WinUILanguageOverride "ca-ES"
Set-WinSystemLocale "ca-ES"
Set-Culture "ca-ES"

Write-Host "A continuació la llista de llenguatges descarregada:"
Get-WinUserLanguageList
}}

# Que no s'apagui la pantalla mai...
# Es torna a canviar al final del guió.
echo "Removing monitor and standby timeout temporarily (=0)"
Powercfg.exe /Change monitor-timeout-dc 0
Powercfg.exe /Change monitor-timeout-ac 0
Powercfg.exe /Change standby-timeout-dc 0
Powercfg.exe /Change standby-timeout-ac 0

# Sincronitza el rellotge...
# Els ordinadors no el solen tenir sincronitzat.
echo "Syncronizing Windows time services"
net stop w32time       # Stop Windows time services (WTS)
w32tm /unregister      # Unregister WTS
w32tm /register        # Register WTS
net start w32time      # Start WTS
w32tm /resync /nowait  # Resynchronize WTS

#############################################################

# Canviar el nom del "workgroup", de l'equip, de l'usuari local:

choice.exe /C yn /D n /m "Do you want to change WORKGROUP to 'TEVI'?"
if ($LASTEXITCODE -eq "1") # 1 for "yes" 2 for "no"
{
Add-Computer -WorkGroupName "TEVI"  # CsDomain
}

$CsDNS = Read-Host -Prompt "Write the new ComputerDNS name (leave blank to remain unchanged)"
Rename-Computer -NewName $CsDNS

# Qui és l'user actual, i qui serà el nou usr?
$LocUsr = (Get-LocalUser | Where Enabled -eq 1).Name
$CompN = (Get-ComputerInfo).CsDNSHostName
Write-Host "The name of this account is $LocUsr"
# El password necessita ser establert com una cadena segura:
$Pass = Read-Host -Prompt "Write the new Password (leave blank to remain unchanged)" -AsSecureString
# Canvia-li el nom segons input manual...
Set-LocalUser -Name $LocUsr -FullName (Read-Host -Prompt "Write the user's FullName (leave blank to remain unchanged)") -Password $Pass

#############################################################

# No separa entre alumnes i professors!!!

# Elimina aplicacions mitjançant cmd.exe:
# AppPackage és molt incomplet, i PowerShell plena d'insectes.
# CMD /C: vol dir còrrer cmd.exe i quan acabi terminar.

# Productes que requereixen input manual, primers: McAfee.

$Mcafee = @(
    "*WebAdvisor*McAfee*" #pot anomenar-se webadvisor *de* o *by* mcafee...
    #"*McAfee LiveSafe*"  #no funciona
  )
foreach ($App in $Mcafee) {
    Write-Verbose -Message ('Removing Package {0}' -f $App)
    # No he trobat manera de fer-ho silenciós:
    Get-Package -Name $App |% {& $_.Meta.Attributes["UninstallString"]}
    # Espera fins que l'usuari tanqui la finestra de desinstal·lació i continuï amb l'script.
    #~choice.exe /C E /m "Press E to continue once $App is uninstalled."
  }

# Elimina d'estranquis "McAfee LiveSafe":
cmd /c '"C:\Program Files\McAfee\MSC\mcuihost.exe"  /body:misp://MSCJsRes.dll::uninstall.html /id:uninstall'
choice.exe /C E /m "Press E to continue once McAfee LiveSafe and WebAdvisor are both uninstalled."

# Comencem per eliminar Microsoft 365, OneNote i OneDrive.

$Packages = @(
  "*Microsoft*365 - en-us*"
  "*Microsoft*365 - es-es*"
  "*Microsoft OneNote - en-us*"
  "*Microsoft OneNote - es-es*"
  "*Microsoft OneDrive*"
  )
foreach ($App in $Packages) {
    Write-Verbose -Message ('Removing Package {0}' -f $App)
    Get-Package -Name $App |% {$UNI = $_.Meta.Attributes["UninstallString"]}
    # Afageix switch silenciós:
    $UNI = $UNI + " DisplayLevel=False"
    # Desinstal·la.
    cmd /c $UNI
  }
# MS. Onedrive es fa el difícil. Arreglo a mig fer: #bare
cmd /c "~\Appdata\Local\Microsoft\OneDrive\[0-9]*\OneDriveSetup.exe  /uninstall"

# Continuem amb el software "sponsorejat"; "ExpressVPN", "Dropbox", "Netflix"...

Write-Verbose -Message ('Removing Package *ExpressVPN* (msi)')
Get-Package -Name "*ExpressVPN*"|Uninstall-Package -Force  #desinstal·la paquet msi.
Start-Sleep 2
Write-Verbose -Message ('Removing Package *ExpressVPN* (alt.)')
Get-Package -Name "*ExpressVPN*"|% {$UNI = $_.Meta.Attributes["UninstallString"]}  #paquet extra.
# Desinstal·la afegint switch silenciós i impedint reinici:
cmd /c $UNI /quiet /norestart
# remove DropBox OEM / 25gb...
Get-Package -Name "*dropbox*"|Uninstall-Package -Force
# remove Netflix...
Get-AppPackage -Name "*Netflix*"|Remove-AppPackage -Force

# Eliminem paquets de HP:

Write-Verbose -Message ('Removing Package *HP Documentation*')
#REVISAR $UNI (afegir switch silenciós)
Get-Package -Name "*HP Documentation*"|% {$UNI = $_.Meta.Attributes["UninstallString"]}
# No necessita switch silenciós, en principi:
cmd /c $UNI /quiet
# Altres assistents d'HP (un paquet msi):
Get-Package -Name "*HP Support Assistant*"| Uninstall-Package -Force
# HP Orbit... no sé què és.
Get-Package -Name "*HP Orbit*"| Uninstall-Package -Force
Get-Package -Name "*HP Customer Experience Enh*"| Uninstall-Package -Force
Get-Package -Name "*HP Support Solutions*"| Uninstall-Package -Force
(Get-WmiObject -Class Win32_Product -Filter "Name = 'HP Registration Service'").Uninstall()
Get-Package -Name "*HP Orbit*"|% {cmd /c $_.Meta.Attributes["UninstallString"] /quiet}


# Eliminem paquets de Lenovo ("Welcome", "Vantage").

Write-Verbose -Message ('Removing Packages *Lenovo Welcome* and *Lenovo Vantage*')

#REVISAR $UNI (afegir switch silenciós)
Get-Package -Name "*Lenovo Welcome*"|% {$UNI = $_.Meta.Attributes["UninstallString"]}
cmd /c $UNI
# No he trobat el desinstal·lador silenciós de "Lenovo Vantage".
Get-Package -Name "*Lenovo Vantage*"|% {$UNI = $_.Meta.Attributes["UninstallString"]}
cmd /c $UNI


#########################################

# Elimina les aplicacions de AppxPackage

$AppXApps = @(

        #Unnecessary Windows 10 AppXApps
        "*Microsoft.BingNews*"
        "*Microsoft.BingWeather*"
        "*Microsoft.GetHelp*"
        "*Microsoft.Getstarted*"
        "*Microsoft.Messaging*"
        "*Microsoft.Microsoft3DViewer*"
        "*Microsoft.MicrosoftOfficeHub*"
        "*Microsoft.MicrosoftSolitaireCollection*"
        "*Microsoft.MinecraftEducationEdition*"
        "*Microsoft.NetworkSpeedTest*"
        "*Microsoft.Office.Sway*"
        "*Microsoft.OneConnect*"
        "*Microsoft.People*"
        "*Microsoft.Print3D*"
        "*Microsoft.SkypeApp*"
        "*microsoft.windowscommunicationsapps*"
        "*Microsoft.WindowsFeedbackHub*"
        "*Microsoft.WindowsMaps*"
        "*Microsoft.Xbox.TCUI*"
        "*Microsoft.XboxApp*"
        "*Microsoft.XboxGameOverlay*"
        "*Microsoft.XboxIdentityProvider*"
        "*Microsoft.XboxSpeechToTextOverlay*"
        "*Microsoft.ZuneMusic*"
        "*Microsoft.ZuneVideo*"
        
        #HP specific apps:
        "*myHP"
        "*HPSupportAssistant"
        "*Discover*HPTouch*"
        
        # Lenovo specific apps:
        "*LenovoUtility*"
        "*LenovoCompanion*"

        #Sponsored Windows 10 AppX Apps
        #Add sponsored/featured apps to remove in the "*AppName*" format
        "*EclipseManager*"
        "*ActiproSoftwareLLC*"
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
        "*Duolingo-LearnLanguagesforFree*"
        "*PandoraMediaInc*"
        "*CandyCrush*"
        "*Wunderlist*"
        "*Flipboard*"
        "*Twitter*"
        "*Facebook*"
        "*Spotify*"
        "*Dropbox*"
        "*McAfeeSecurity*"
        "*LinkedIn*"
        "*Disney*"
        "*Netflix*"

        #Optional: Typically not removed but you can if you need to for some reason
        #"*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
        #"*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
        #"*Microsoft.MicrosoftStickyNotes*"
        #"*Microsoft.MSPaint*"
        #"*Microsoft.WindowsAlarms*"
        #"*Microsoft.WindowsCalculator*"
        #"*Microsoft.WindowsCamera*"
        #"*Microsoft.Windows.Photos*"
        #"*Microsoft.WindowsSoundRecorder*"
        #"*Microsoft.WindowsStore*"
    )
    foreach ($App in $AppXApps) {
        Write-Verbose -Message ('Removing AppxPackage {0}' -f $App)
        Get-AppxPackage -Name $App | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxPackage -Name $App -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $App | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }


#########################################

# Seria interessant desanclar rajoles del menú d'inici...

Function UnpinStart {
    # https://superuser.com/a/1442733
    #Requires -RunAsAdministrator
    # cita: Sycnex/Windows10Debloater @github

$START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@

    $layoutFile="C:\Windows\StartMenuLayout.xml"

    #Delete layout file if it already exists
    If(Test-Path $layoutFile)
    {
        Remove-Item $layoutFile
    }

    #Creates the blank layout file
    $START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII

    $regAliases = @("HKLM", "HKCU")

    #Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
    foreach ($regAlias in $regAliases){
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        IF(!(Test-Path -Path $keyPath)) { 
            New-Item -Path $basePath -Name "Explorer"
        }
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
        Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
    }

    #Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
    Stop-Process -name explorer
    Start-Sleep -s 5
    $wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
    Start-Sleep -s 5

    #Enable the ability to pin items again by disabling "LockedStartLayout"
    foreach ($regAlias in $regAliases){
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
    }

    #Restart Explorer and delete the layout file
    Stop-Process -name explorer

    # Uncomment the next line to make clean start menu default for all new users
    #Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\

    Remove-Item $layoutFile
}
# Executa la funció immediatament:
UnpinStart
 

#########################################
    
# Recupera que el monitor s'apagui...
echo "Changing monitor and standby timeout while disconnected to 15 minutes"
Powercfg.exe /Change monitor-timeout-dc 15
Powercfg.exe /Change monitor-timeout-ac 0
Powercfg.exe /Change standby-timeout-dc 15
Powercfg.exe /Change standby-timeout-ac 0

# Reinicia:
echo "##                                      ##"
echo "## Restarting computer after Uninstalls ##"
echo "##                                      ##"
Start-Sleep 60
Restart-Computer

