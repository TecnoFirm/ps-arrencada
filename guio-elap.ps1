
# Preferència de verbositat: quanta informació vols veure a la terminal?
# De manera predeterminada és "SilentlyContinue", que amaga info.

# Tria: /C = Choices [Y, N]
#       /D = Default
#       /t = time-out until default
choice.exe /C yn /D y /t 15 /m "Do you want the script to be verbose? 15 secs to decide."
if ($LASTEXITCODE -eq "1") # 1 for "yes" 2 for "no"
{
$VerbosePreference = "Continue"
}
else
{
$VerbosePreference = "SilentlyContinue"
}

if ((Get-WinSystemLocale) -ne "ca-ES") # Si el locale NO ÉS "ca-ES";
# Pregunta si el volen canviar...
{
choice.exe /C yn /D y /t 15 /m "Do you want the locale be changed to ca-ES? 15 secs to decide."
if ($LASTEXITCODE -eq "1") # 1 for "yes" 2 for "no"
{
Set-WinSystemLocale ca-ES
Start-Sleep 2
Get-WinSystemLocale
}}

# Si la política d'execució és restringida, canvia-ho.
# temporalment per fer les actualitzacions que durem
# a terme al guió `guio-wiup.ps1`.
if ((Get-ExecutionPolicy) -eq "Restricted") {
  Set-ExecutionPolicy "Unrestricted"
}

# Que no s'apagui la pantalla mai...
# Es torna a canviar a la configuració inicial amb el guio-conf.ps1 

Powercfg.exe /Change monitor-timeout-dc 0
Powercfg.exe /Change monitor-timeout-ac 0
Powercfg.exe /Change standby-timeout-dc 0
Powercfg.exe /Change standby-timeout-ac 0

# Sincronitza el rellotge...
# Els ordinadors no el solen tenir sincronitzat.

net stop w32time       # Stop Windows time services (WTS)
w32tm /unregister      # Unregister WTS
w32tm /register        # Register WTS
net start w32time      # Start WTS
w32tm /resync /nowait  # Resynchronize WTS

# Canvia el nom del "workgroup" i de l'equip:
Add-Computer -WorkGroupName "TEVI"  # CsDomain
$CsDNS = Read-Host -Prompt "Write the new ComputerDNS name"
Rename-Computer -NewName $CsDNS

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

# Continuem amb el software "sponsorejat" "ExpressVPN".

Write-Verbose -Message ('Removing Package *ExpressVPN* (msi)')
Get-Package -Name "*ExpressVPN*"|Uninstall-Package -Force  #desinstal·la paquet msi.
Start-Sleep 2
Write-Verbose -Message ('Removing Package *ExpressVPN* (alt.)')
Get-Package -Name "*ExpressVPN*"|% {$UNI = $_.Meta.Attributes["UninstallString"]}  #paquet extra.
# Afageix switch silenciós i impedeix reinici:
$UNI = $UNI + " /quiet /norestart"
# Desinstal·la
cmd /c $UNI

# Eliminem Documentació de HP:

Write-Verbose -Message ('Removing Package *HP Documentation*')
Get-Package -Name "*HP Documentation*"|% {$UNI = $_.Meta.Attributes["UninstallString"]}
# No necessita switch silenciós:
cmd /c $UNI

# Eliminem paquets de Lenovo "Welcome" i "Vantage".

Write-Verbose -Message ('Removing Packages *Lenovo Welcome* and *Lenovo Vantage*')

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
    
    # Reinicia:
    echo "##                                      ##"
    echo "## Restarting computer after Uninstalls ##"
    echo "##                                      ##"
    Start-Sleep 10
    Restart-Computer


