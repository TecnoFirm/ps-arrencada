
# Source to get the files from.
$githubLatestReleases = 'https://api.github.com/repos/rustdesk/rustdesk/releases/latest'   
# Put downloaded files in the user's Desktop.
cd ~\Desktop
# Get the correct architecture.
if ((Get-WmiObject win32_operatingsystem | select osarchitecture).osarchitecture -like "*64*")
{
  Write-Host "64-bit OS"
  $githubLatestExe = (((Invoke-WebRequest $gitHubLatestReleases) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern 'x86_64.exe').Line
} else {
  Write-Host "32-bit OS"
  $githubLatestExe = (((Invoke-WebRequest $gitHubLatestReleases) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern 'x86-sciter.exe').Line
}
# Download the file.
Invoke-WebRequest $githubLatestExe -OutFile 'rustdesk_latest.exe'

