
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

# Si la política d'execució és restringida, canvia-ho.
# temporalment per fer les actualitzacions.
if ((Get-ExecutionPolicy) -eq "Restricted") {
  Set-ExecutionPolicy "Unrestricted"
}

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
Start-Sleep 3

# Carregar la llista d'actualitzacions...
Get-WindowsUpdate
# Espera uns segons, per si es volen llegir/frenar.
Start-Sleep 10

# Instal·lar tot el que s'ha trobat i reinicia més tard:
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

Write-Host "##                                      ##"
Write-Host "## Restarting Computer to apply Updates ##"
Write-Host "##                                      ##"
Start-Sleep 20
Restart-Computer


