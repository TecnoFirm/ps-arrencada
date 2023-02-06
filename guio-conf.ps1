
# Preferència de verbositat: quanta informació vols veure a la terminal?
# De manera predeterminada és "SilentlyContinue", que amaga info.

# Tria: /C = Choices [Y, N]
#       /D = Default
#       /t = time-out until default
choice.exe /C yn /D n /t 15 /m "Do you want the script to be verbose? 15 secs to decide."
if ($LASTEXITCODE -eq "1") # 1 for "yes" 2 for "no"
{
  $VerbosePreference = "Continue"
} else {
  $VerbosePreference = "SilentlyContinue"
}

#################################################

# Emmagatzema la MAC dins el \\NAS? Intencions, somnis d'ivori:

choice.exe /C yn /m "Do you want to store the MAC Adress inside 'D:\extres\mac.txt'?"
if ($LASTEXITCODE -eq "1") # 1 for "yes" 2 for "no"
{
  $mac = (Get-NetAdapter -Name "Wi-Fi").MacAddress
  $txt = "$CompN`t$LocUsr`t$mac"  # `t = TAB (dins cadena de text entre cometes)
  # Si hi ha connectat el pendrive al socket D:, guarda el fitxer allí.
  if (Test-Path "D:\extres") 
  {
  # Hi ha connectat el pendrive...
      Write-Host "S'ha guardat mac.txt al pendrive (D:\extres\mac.txt)"
      echo $txt >> "D:\extres\mac.txt"
  # Si esta connectat a un altre socket...
  } elseif (Test-Path "E:\extres") {
      Write-Host "S'ha guardat mac.txt al pendrive (E:\extres\mac.txt)"
      echo $txt >> "E:\extres\mac.txt"
  # Sense pendrive s'envia a l'escriptori.
  } else {
      Write-Host "No hi ha connectat el pen-drive;"
      Write-Host "S'ha guardat 'mac.txt' a l'escriptori"
      echo $txt >> "~\Desktop\mac.txt"
}}

##############################################

# Canvia la configuració de notificacions.

# Elimina-les completament:
Write-Host "Disabling Action Center..."
# Crea un arxiu si no existeix...
If (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
  New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
  Write-Verbose "S'ha CREAT el camí que desactiva el centre de notificacions"

} else {  # Si l'arxiu existeix, canvia config...
  Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
  Write-Verbose "S'ha MODIFICAT el camí que desactiva el centre de notificacions"
}
# Altres paràmetres...
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0

##############################################

# Activa accessos directes predeterminats ("mi equipo", brossa...).

$Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$Names = @(
  "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"  # mi equipo
  "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"  # xarxa
  "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"  # carpeta d'usuari
  "{645FF040-5081-101B-9F08-00AA002F954E}"  # contenidor brossa
# "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"  # tauler de control
)
Write-Host "Creating Desktop Shortcuts..."
foreach ($short in $Names) {
    $exist = "Get-ItemProperty -Path $Path -Name $short"
    if ($exist) {
        Set-ItemProperty -Force -Path $Path -Name $short -Value 0
    } else {
        New-ItemProperty -Force -Path $Path -Name $short -Value 0
    }
}
# Aplicar accessos directes dona problemes (pantalla blava!?).
# Anar amb compte.

#####################################################################

# Copia la carpeta "soft" a Documents...
# A partir d'una unitat USB exterior (pendrive) pre-preparada.

if (Test-Path "D:\extres\Setup-Tevi-09-2022") 
{
# Hi ha connectat el pendrive...
# Copia la carpeta de soft a ~/Documents
    cp -r "D:\extres\Setup-Tevi-09-2022\soft" "~/Documents"
    Write-Host "S'ha copiat soft automàticament (de D:\extres)"
} elseif (Test-Path "E:\extres\Setup-Tevi-09-2022") {
    cp -r "E:\extres\Setup-Tevi-09-2022\soft" "~/Documents"
    Write-Host "S'ha copiat soft automàticament (de E:\extres)"
} else {
    Write-Host "No hi ha connectat el pen-drive;"
    Write-Host "Copia manualment la carpeta de software a documents"
}

Read-Host -Prompt "Has '~/Documents/soft' been created?"
cd "~/Documents/soft"

Write-Host 'Installing Google Chrome...'
.\ChromeSetup_cat.exe /silent /install 
Start-Sleep 30

Write-Host 'Installing LibreOffice...'
.\LibreOffice*Win_x64.msi RebootYesNo=No /qn
Start-Sleep 30

Write-Host 'Installing VLC media player (lang=ca)...'
.\vlc*win64.exe /L=1027 /S
Start-Sleep 30

Write-Host 'Installing Adobe Acrobat Reader...'
.\AcroRdrDC*_ca_ES.exe /sAll /rs 
Start-Sleep 30

Write-Host 'Manually installing Avast...'
.\avast_free_antivirus_setup_online.exe
# Pausa fins que acabi tot plegat...
cmd /c pause

# Es podrien fer canvis al DisplayLevel (revisar elap) per amagar l'instal·lador.
# Tot i això és molt llarg i en línia; val la pena que sigui manual.
choice.exe /C yn /m "Do you want OfficeSetup to be executed and installed?"
if ($LASTEXITCODE -eq 1) {
  Write-Host 'Manually Installing Office...'
  .\OfficeSetup.exe
  # Pausa fins que acabi tot plegat...
  cmd /c pause
  $office_install = "1"
} elseif ($LASTEXITCODE -eq 2) {
  Write-Host 'Office packet was not installed'
}

#######################################################

Write-Host "Creant accessos directes al NAS i Escriptori Remot"

choice.exe /C ap /N /m "Is it a student (A) or teacher (P) installation?"
if ($LASTEXITCODE -eq "2") 
{
  cp ".\NAS.lnk" "~\Desktop"
  cp ".\professors (NAS).lnk" "~\Desktop"
  cp ".\users (NAS).lnk" "~\Desktop"
  cp ".\Escriptori Remot.rdp" "~\Desktop"
} elseif ($LASTEXITCODE -eq "1") {
  # cp ".\Acces Alumne.lnk" "~/Desktop"
  # Crec que cap alumne usa l'Accés Alumnes
}

# Crea accessos directes pel programari Office:
#ARREGLAR
#https://stackoverflow.com/questions/54728510/how-to-follow-a-symbolic-soft-link-in-cmd-or-powershell

# Abans de res, revisa que l'Office s'hagi instal·lat...
if ($office_install -eq "1") {
  # Es necessita accés a la carpeta de programari del menú d'inici:
  if (Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs") {
    Write-Verbose "Creating shortcuts to MS-Office software..."
    cd "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    # Aquests son els links que ens interessa copiar des de la carpeta anterior fins a l'escriptori...
    $Lnks = @(
      "Word.lnk"
      "PowerPoint.lnk"
      "Excel.lnk"
      "Publisher.lnk"
    )
    foreach ($l in $Lnks) {
      # Troba l'origen dels links de la carpeta anterior...
      $source=((New-Object -ComObject WScript.Shell).CreateShortcut("$PWD/$l").TargetPath)
      New-Item -Type SymbolicLink -Value $source -Path "~\Desktop" -Name $l
    }
  } else {
    # Si no es troba el camí fins a Start Menu, warning...
    Write-Host "Path to StartMenu has not been found."
    Write-Host "No shortcuts to Office products have been created."
  }
}

# Catalanitzador de softcatalà (revisió de l'ús dels paquets catalans)
.\CatalanitzadorPerAlWindows.exe
cmd /c pause

# Engega el programari que necessita config inicial?
# i.e. Chrome, VLC, etc.

# Drivers Impressora:
#~.\*drivers_canon_8205*
#~Write-Host "Installing printer drivers..."
#~Write-Host "Pressing a key will prompt reboot!"
#~cmd /c pause

#############################################

# Retorna la conf. predeterminada pel que fa
# a standby i monitor time-out...

Powercfg /Change monitor-timeout-ac 60
Powercfg /Change monitor-timeout-dc 15
Powercfg /Change standby-timeout-ac 60
Powercfg /Change standby-timeout-dc 15

# Recordatori per a configurar el Wi-Fi:
Write-Host "Recorda configurar el Wi-Fi segons fós necessari!`n"
# shows the name of the wifi the pc is connected to...
netsh wlan show interfaces

# Buida i elimina carpeta PowerShell dins "Documents".
  # Vés a $HOME (si estava dins /soft no permet eliminar-lo).
  cd ~
  # Elimina recursivament (prem opció 'o' per confirmar).
  rm -Confirm -r "~\Documents\*"

Write-Host "##                                                     ##"
Write-Host "## Restarting Computer to apply Short-cuts and Configs ##"
Write-Host "##                                                     ##"
Start-Sleep 10
Restart-Computer

