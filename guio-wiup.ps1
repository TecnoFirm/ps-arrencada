
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

# Descarrega el mòdul necessari per gestionar
# WindowsUpdate a través de PowerShell...
Install-Module PSWindowsUpdate -Force

# Carregar la llista d'actualitzacions...
Get-WindowsUpdate
# Espera uns segons, per si es volen llegir/frenar.
Start-Sleep 10

# Si la política d'execució és restringida, canvia-ho.
# temporalment per fer les actualitzacions.
if ((Get-ExecutionPolicy) -eq "Restricted") {
  Set-ExecutionPolicy "Unrestricted"
}

# Instal·lar tot el que s'ha trobat i reinicia:
Get-WindowsUpdate -AcceptAll -Install -AutoReboot


