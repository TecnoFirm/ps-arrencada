
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

# Retorna la conf. predeterminada pel que fa
# a la política d'execució de guions powershell
#
# (ho haviem canviat temporalment per fer WindowsUpdate)

if ((Get-ExecutionPolicy) -eq "Unrestricted") {
  Set-ExecutionPolicy "Restricted"
}

#################################################

# Canviar el nom de l'equip i de l'usuari local:

#    # Qui és l'user actual, i qui serà el nou usr?
#    Get-LocalUser | Where {$_.Enabled -eq 1} |% {$LocUsr = $_.Name}
#    $NewUsr = Read-Host -Prompt "Write the new LocalUser name"
#    # Canvia-li el nom segons input manual...
#    Rename-LocalUser -Name $LocUsr -NewName $NewUsr
#    
#    # Canvia el nom del "workgroup" i de l'equip:
#    Add-Computer -WorkGroupName "TEVI"  # CsDomain
#    $CsDNS = Read-Host -Prompt "Write the new ComputerDNS name"
#    Rename-Computer -NewName $CsDNS

#############################################

# Retorna la conf. predeterminada pel que fa
# a standby i monitor time-out...

Powercfg /Change monitor-timeout-ac 4
Powercfg /Change monitor-timeout-dc 10
Powercfg /Change standby-timeout-ac 10
Powercfg /Change standby-timeout-dc 20

##############################################

# Canvia la configuració de notificacions.

# Elimina-les completament:
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

######################################################################

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
        Set-ItemProperty -Force -Path $Path -Name $short -Value 0
    }
    Else {
        New-ItemProperty -Force -Path $Path -Name $short -Value 0
    }
}
# Aplicar accessos directes dona problemes (pantalla blava!?).
Write-Host "##                                                     ##"
Write-Host "## Restarting Computer to apply Short-cuts and Configs ##"
Write-Host "##                                                     ##"
Start-Sleep 10
Restart-Computer


