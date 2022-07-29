
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

Write-Verbose -Message ('Removing Package *ExpressVPN* (msi)' -f $App)
Get-Package -Name "*ExpressVPN*"|Uninstall-Package -Force  #desinstal·la paquet msi.
Start-Sleep 2
Write-Verbose -Message ('Removing Package *ExpressVPN* (alt.)' -f $App)
Get-Package -Name "*ExpressVPN*"|% {$UNI = $_.Meta.Attributes["UninstallString"]}  #paquet extra.
# Afageix switch silenciós i impedeix reinici:
$UNI = $UNI + " /quiet /norestart"
# Desinstal·la
cmd /c $UNI

# Eliminem Documentació de HP:

Write-Verbose -Message ('Removing Package *HP Documentation*' -f $App)
Get-Package -Name "*HP Documentation*"|% {$UNI = $_.Meta.Attributes["UninstallString"]}
# No necessita switch silenciós:
cmd /c $UNI



        Write-Verbose -Message ('Removing Package {0}' -f $App)
        Get-Package -Name $App |Uninstall-Package -Force  # sols per paquets msi...
        # # La majoria dels paquets es desinstal·len a continuació:
        # # Aconsegueix la cadena amb l'executable de desinstal·lació.
        # Get-Package -Name $App |% {$UNI = $_.Meta.Attributes["UninstallString"]} 
        # # Executa desinstal·lació.
        # cmd /c $UNI

    }

# # HP Documentation App...
# Get-Package "*HP Documentation*"|% {$UNI = $_.Meta.Attributes["UninstallString"]} ; CMD /C $UNI

# # Elimina Microsoft 365 (tant en-us com es-es)
# Get-Package "*Microsoft 365*"|% {$UNI = $_.Meta.Attributes["UninstallString"]} ; CMD /C $UNI

# Elimina Microsoft OneDrive
# Get-Package "*Microsoft Onedrive*"|% {$UNI = $_.Meta.Attributes["UninstallString"]} ; 
#     foreach ($App in $UNI) {
#         Write-Verbose -Message ('Removing Package {0}' -f $App)
#         cmd /c $App
#     }
# 
# # Elimina Microsoft OneNote
# Get-Package "*Microsoft OneNote*"|% {$UNI = $_.Meta.Attributes["UninstallString"]} ; CMD /C $UNI
# 
# # Elimina productes de McAfee.
# Get-Package "*McAfee*"|% {$UNI = $_.Meta.Attributes["UninstallString"]} ; CMD /C $UNI

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


