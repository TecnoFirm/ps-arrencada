
# Preferència de verbositat: quanta informació vols veure a la terminal?
# De manera predeterminada és "SilentlyContinue", que amaga info.

# Tria: /C = Choices [Y, N]
#       /D = Default
#       /t = time-out until default
choice.exe /C yn /D n /t 15 /m "Do you want the script to be verbose? 15 secs to decide."
if ($LASTEXITCODE -eq "1") # 1 for "yes" 2 for "no"
{
    Write-Host "Script will be verbose"
    $VerbosePreference = "Continue"
}
else
{
    Write-Host "Script will NOT be verbose"
    $VerbosePreference = "SilentlyContinue"
}

####################################################

# Evalua si existeix un fitxer apte per emmagatzemar les dades
# dins el drive USB. 
#
# En cas negatiu, prepara'l (crea una capçalera 
# per a organitzar les dades)
$cap =  "Comp-Name`tIPv4-Addr`tMAC-WiFi`tOSystem`tRoom`tDate-Retr`tOld-Name`tNotes`n"
$cap += "---------`t---------`t--------`t-------`t----`t---------`t--------`t-----"

# Busca un socket (D:, E:) on hi hagi connectat un drive USB
# qualsevol que contingui una carpeta anomenada "extres"...
if (Test-Path "D:\extres\Retriever") 
{
# Hi ha connectat el pendrive al socket `D:`...
    $filepath = "D:\extres\Retriever\data.tab"
    if (Test-Path $filepath) {
        Write-Host "The file 'data.tab' does already exist in 'D:\extres\Retriever'."
    }
    else {
        Write-Host "The file 'data.tab' does not exist."
        Write-Host "Creating the file at 'D:\extres\Retriever', adding the header..."
        echo $cap > $filepath
    }
} elseif (Test-Path "E:\extres\Retriever") {
# Hi ha connectat el pendrive al socket `E:`...
    $filepath = "E:\extres\Retriever\data.tab"
    if (Test-Path $filepath) {
        Write-Host "The file 'data.tab' does already exist in 'E:\extres\Retriever'."
    }
    else {
        Write-Host "The file 'data.tab' does not exist."
        Write-Host "Creating the file at 'E:\extres\Retriever', adding the header..."
        echo $cap > $filepath
    }
} else {
# No hi ha connectat el pendrive a cap socket...
    Write-Host "No hi ha connectat el drive USB als primers dos sockets (E:, D:)."
    Write-Host "Es guardaràn les dades a l'escriptori (~/Desktop)."
    $filepath = "~\Desktop\data.tab"
    echo $cap > $filepath
}

####################################################

# Obté certa informació de manera automàtica...

# Canvia el nom del "workgroup"...
choice.exe /C yn /m "Do you want to add the computer to 'TEVI' domain?"
if ($LASTEXITCODE -eq 1) {
    Add-Computer -WorkGroupName "TEVI"  # CsDomain
    Write-Host "Added the Computer to 'TEVI' workgroup domain."
} else {
    Write-Host "The workgroup domain remains unchanged."
}

# Obtén el nom de l'equip...
$CNOld = (Get-ComputerInfo).CsDNSHostName
Write-Host "The current Computer (DNS) Name is $CNOld"
# Obtén el Sistema Operatiu de l'equip:
$os = (Get-ComputerInfo).WindowsProductName
Write-Host "The current OS is $os"

# Tria si es vol canviar el nom de l'equip,
# i per quin nom el voldries canviar...
choice.exe /C yn /m "Do you want to change the Computer name?"
if ($LASTEXITCODE -eq "1") # 1 for "yes" 2 for "no"
{Rename-Computer -NewName (Read-Host -Prompt "Write the new ComputerDNS name")}

# Aconsegueix saber qui és l'usuari actual i el nom
# de la computadora...
$LocUsr = (Get-LocalUser | Where Enabled -eq 1).Name
$CompN = (Get-ComputerInfo).CsDNSHostName
Write-Verbose "The name of the local user account/s is/are:"
# Imprimeix una llista dels 'local users' (si n'hi ha més d'un)...
foreach ($item in $LocUsr) {Write-Verbose " * $item"}
Write-Verbose "New computer name: $CompN"

# Adreça IPv4 d'ethernet...
# Primer de tot, revisa que estigui connectat per Ethernet:
if ((Get-NetAdapter | Where-Object Name -eq "Ethernet").status -eq "Disconnected") {
    # No esta connectat:
    Write-Host "Ethernet connection is found to be disconnected."
    Write-Host "Will not retrieve IPv4."
    $ipv4 = ""  # ...Crea una variable buida
} else { # Si que esta connectat, extreu IPv4...
    Write-Host "Ethernet connection is up, retrieving their IPv4 address..."
    $ipv4 = (Get-NetIPAddress -AddressFamily ipv4 -InterfaceAlias ethernet).ipaddress
    Write-Verbose "IPAddress: $ipv4"
}

# Check if Wi-Fi exists and it is not null...
if ((Get-NetAdapter | Where-Object Name -eq "Wi-Fi")) {
    # Wi-Fi value is NOT null
    Write-Host "Wi-Fi connection is up, retrieving their MAC address..."
    $mac = (Get-NetAdapter -Name "Wi-Fi").MacAddress
    Write-Verbose "Wi-Fi MAC.Address: $mac"
} else {
    # Wi-Fi value is null
    Write-Host "Wi-Fi connection has not been found."
    Write-Host "Will not retrieve their MAC.address."
    $mac = ""  # ...Crea una variable buida
}

# Dia/Mes/Any en el qual s'ha fet l'anàlisi de característiques...
$dia = Get-Date -UFormat "%m/%d/%Y"
Write-Verbose "Date of info. retrieval: $dia"

####################################################

# Obtén la info que no es pot demanar de
# manera automàtica (aula, notes, etc.)

$room = Read-Host -Prompt "Where is the computer located at?"

####################################################

# Emmagatzema les dades dins el drive USB:

# Ordena la info dins la variable '$data':
$data += $CompN+"`t"+$ipv4+"`t"+$mac+"`t"+$os+"`t"+$room+"`t"+$dia+"`t"+$CNOld+"`t"
Write-Host "Column of data retrieved:"
Write-Host $data

# Notes... S'han de separar entre ';' automàticament.
# Enregistra notes de manera individual fins que la variable sigui buida.
$notes = Read-Host -Prompt "Mouse/Keyboard/Screen malfunction?"
"Is there anything special you want to further register?"

##############################################

Write-Host "##                                               ##"
Write-Host "## The script has finished gathering information ##"
Write-Host "##                                               ##"
Start-Sleep 10

