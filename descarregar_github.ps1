
cd ~\Desktop
$githubLatestReleases = 'https://api.github.com/repos/rustdesk/rustdesk/releases/latest'   
$githubLatestExe = (((Invoke-WebRequest $gitHubLatestReleases) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern 'x86_64.exe').Line
Invoke-WebRequest $githubLatestExe -OutFile 'rustdesk_latest.exe'


if ((Get-WmiObject win32_operatingsystem | select osarchitecture).osarchitecture -like "*64*")
{
  Write "64-bit OS"
} else {
  Write "32-bit OS"
}

