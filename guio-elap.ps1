
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

# Abans de suprimir Apps, canvia la configuració de notificacions.
# Elimina completament les notificacions:
Write-Host "Disabling Action Center..."
# Crea un arxiu si no existeix...
If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
  New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
}
# Si l'arxiu existeix, canvia config...
Else {
  Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
}
# Altres paràmetres...
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0

# Activa accessos directes predeterminats ("mi equipo", brossa...).

$Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$Names = @(
  "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"  # mi equipo
  "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"  # xarxa
  "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"  # carpeta d'usuari
  "{645FF040-5081-101B-9F08-00AA002F954E}"  # contenidor brossa
# "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"  # panell de control
)
Write-Host "Creating Desktop Shortcuts..."

foreach ($short in $Names) {
    $exist = "Get-ItemProperty -Path $Path -Name $short"
    if ($exist) {
        Set-ItemProperty -Path $Path -Name $short -Value 0
    }
    Else {
        New-ItemProperty -Path $Path -Name $short -Value 0
    }
}


#############################################################

# Elimina aplicacions mitjançant cmd.exe:
# AppPackage és molt incomplet, i PowerShell plena d'insectes.
# CMD /C: vol dir còrrer cmd.exe i quan acabi terminar.

# Productes que requereixen input manual, primers: McAfee.

$x = "*WebAdvisor by McAfee*"
Write-Verbose -Message ('Removing Package {0}' -f $x)
# No he trobat manera de fer-ho silenciós:
Get-Package -Name $x |% {& $_.Meta.Attributes["UninstallString"]}
# Espera fins que l'usuari tanqui la finestra de desinstal·lació i continuï amb l'script.
.\choice.exe /C E /m "Press E to continue once McAfee is uninstalled."

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


