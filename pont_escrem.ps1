
# PONT ENTRE ESCRIPTORIS REM.

# Assegura que té accés admin per eliminar/instal·lar programari.
#Requires -RunAsAdministrator

# Aconsegueix el camí fins al desinstal·lador.
Get-Package "*AnyDesk*" |% {$AD_uninstaller = $_.Meta.Attributes["UninstallString"]}
# Substitueix l'opció de desinstal·lació manual per una d'autònoma (silenciosa).
$AD_uninstaller = $AD_uninstaller.replace("--uninstall", "--remove")
# Run.
cmd /c $AD_uninstaller

# Intentar eliminar arxius residuals.
# Com que semblen pocs arxius, demana confirmació manual (-Confirm).
# Elimina arxius dins de carpetes recursivament (-Recurse).
cd "~/Appdata/Roaming"
rm "*AnyDesk*" -Recurse -Confirm
cd "C:/Program Files (x86)"
rm "*AnyDesk*" -Recurse -Confirm
cd "~/Desktop"
rm "*Anydesk*" -Recurse -Confirm

# Source to get the new files from.
$githubLatestReleases = "https://api.github.com/repos/rustdesk/rustdesk/releases/latest"
# Put downloaded files in the user's Desktop.
cd ~\Desktop
# Get the correct architecture.
if ((Get-WmiObject win32_operatingsystem | select osarchitecture).osarchitecture -like "*64*")
{
  Write-Host "64-bit OS"
  $githubLatestExe = (((Invoke-WebRequest $gitHubLatestReleases) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern "x86_64.exe").Line
} else {
  Write-Host "32-bit OS"
  $githubLatestExe = (((Invoke-WebRequest $gitHubLatestReleases) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern "x86-sciter.exe").Line
}
# Download the file.
Invoke-WebRequest $githubLatestExe -OutFile "rustdesk_latest.exe"
# Install RustDesk.
./rustdesk_latest.exe --silent-install
# Remove installer.
rm "rustdesk_latest.exe" -Confirm

# If you manually setup a client, you can retrieve the RustDesk2.toml (in the user folder).
# Then, use `--import-config 'file.toml'`
# (from RustDesk manual, <https://rustdesk.com/docs/en/client/>)

