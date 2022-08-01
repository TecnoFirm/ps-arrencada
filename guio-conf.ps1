
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

# Qui és l'user actual, i qui serà el nou usr?
Get-LocalUser | Where {$_.Enabled -eq 1} |% {$LocUsr = $_.Name}
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
# Anar amb compte.

#####################################################################

# Instal·lacions de programari a partir del \\NAS

# Es pot emprar la variable "$LocUsr".
# Copiar la carpeta i entrar-hi:
# net use z: \\NAS\Informatica\Installers\
# cp -r z:`` c:\Users\*\Desktop\.
# cd Desktop\Installers\

# Instal·lar LibreOffice:
.\LibreOffice*Win_x64.msi RebootYesNo=No /qn
Start-Sleep 30

# Instal·lar Google Chrome:
.\ChromeSetup_cat.exe /silent /install 
Start-Sleep 30

# Instal·lar VLC media player:
# (en català, Llengua=1027)
.\vlc*win64.exe /L=1027 /S
Start-Sleep 30

# Instal·lar Acrobat Reader:
.\AcroRdrDC*_ca_ES.exe /sAll /rs 
Start-Sleep 30

# Instal·lar (MANUALMENT) Avast Free:
.\avast_free_antivirus_setup_online.exe
# Pausa fins que acabi tot plegat...
cmd /c pause

# Instal·lar (MANUALMENT) Office:
.\OfficeSetup.exe
# Pausa fins que acabi tot plegat...
cmd /c pause

# Crea accessos directes pel programari Office:

# Canvia a la carpeta origen.
cd "C:\Program Files\Microsoft Office\root\Office16\"
# Crea taula amb variables pel Word, PowerPoint, etc.
$Origin = @(
    [pscustomobject]@{link = "Word.lnk"; value=".\WINWORD.exe"}
    [pscustomobject]@{link = "PowerPoint.lnk"; value=".\POWERPNT.EXE"}
    [pscustomobject]@{link = "Excel.lnk"; value=".\EXCEL.EXE"}
    [pscustomobject]@{link = "Publisher.lnk"; value=".\MSPUB.EXE"}
)
for ($i = 0; $i -lt $cars.Length; $i++)
{
  $Val = $Origin.value[$i]
  $Lnk = $Origin.link[$i]
  # Crea link a l'escriptori per a cada programari.
  New-Item -Type SymbolicLink -Value $Val -Path "~\Desktop" -Name $Lnk
}

# Engega el programari que necessita config inicial?
# i.e. Chrome, VLC, etc.

# Drivers Impressora:
.\*drivers_canon_8205*

# Buida i elimina carpeta PowerShell dins "Documents".
rm -Confirm -r "~\Documents\*"

Write-Host "##                                                     ##"
Write-Host "## Restarting Computer to apply Short-cuts and Configs ##"
Write-Host "##                                                     ##"
Start-Sleep 10
Restart-Computer


