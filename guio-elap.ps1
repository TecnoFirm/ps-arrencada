
# Preferència de verbositat: quanta informació vols veure a la terminal?
# De manera predeterminada és "SilentlyContinue", que amaga info.

# Tria: /C = Choices [Y, N]
#       /D = Default
#       /t = time-out until default
.\choice.exe /C yn /D n /t 15 /m "Do you want the script to be verbose? 15 secs to decide."
if ($LASTEXITCODE -eq "1") # 1 for "yes" 2 for "no"
{
$VerbosePreference = "Continue"
}
else
{
$VerbosePreference = "SilentlyContinue"
}

# Elimina aplicacions mitjançant cmd.exe:
# AppPackage és molt incomplet, i PowerShell plena d'insectes.
# CMD /C: vol dir còrrer cmd.exe i quan acabi terminar.

# Comencem per eliminar Microsoft 365, OneNote i OneDrive.

$Packages = @(
  "*Microsoft 365 - en-us*"
  "*Microsoft 365 - es-es*"
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

# Eliminem productes McAfee.

$x = "*WebAdvisor by McAfee*"
Write-Verbose -Message ('Removing Package {0}' -f $x)
# No he trobat manera de fer-ho silenciós:
Get-Package -Name $x |% {& $_.Meta.Attributes["UninstallString"]}


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
    echo "##               ##"
    echo "## REINICI EN 10 ##"
    echo "##               ##"
    Start-Sleep 10
    Restart-Computer


