
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

# Quin mètode s'emprarà per l'actualització?

.\choice.exe /C 123 /D 3 /t 60 /m "Which method will be employed? 1.PSWindowsUpdate; 2.cmd wuauclt; 3.Manually"
if ($LASTEXITCODE -eq "1") # 1 for "1", 2 for "2"...
{
  # Descarrega el mòdul necessari per gestionar
  # WindowsUpdate a través de PowerShell, si no estava
  # prèviament instal·lat.
  #if (Get-InstalledModule PSWindowsUpdate -ErrorAction "SilentlyContinue") {
  #  Write-Verbose "Module PSWindowsUpdate already installed"
  #}
  #Else {
  #  Install-Module PSWindowsUpdate -Force
  #}
  # Molt sovint és millor forçar la instal·lació sempre,
  # encara que hi sigui prèviament instal·lat:
  Install-Module PSWindowsUpdate -Force
  
  # Importa el mòdul
  Import-Module PSWindowsUpdate
  Start-Sleep 10
  
  # Instal·lar tot el que s'ha trobat i reinicia més tard:
  # La opció `-MicrosoftUpdate` actualitza paquets Office, etc.
  Get-WindowsUpdate -AcceptAll -Install -AutoReboot
}
elseif ($LASTEXITCODE -eq "2")
{
  # no té barra de progrés
  cmd /c wuauclt /detectnow /updatenow
  # obre el panell de control per veure si tot rutlla.
  control.exe update
}
elseif ($LASTEXITCODE -eq "3")
{
  control.exe update
}


