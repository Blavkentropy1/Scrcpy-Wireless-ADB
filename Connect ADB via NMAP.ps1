<# 
    Requires: .\adb.exe (included in SCRCPY files) and NMAP
    Assumption: NMAP is set as an environmental variable
    Description: Wirelessly connect ADB to a device and pair ADB if required, using NMAP to find a random port
#>

# =========================[ Parameters ]============================
$Phone_IP = "192.168.0.101"  # Update to your phone's IP address

# =========================[ Optional Variables ]====================
# Uncomment the following lines to manually set parameters
# $Phone_IP = Read-Host -Prompt "Phone IP"

# =========================[ Start Script ]===========================

Do {
    # Start port scan
    Write-Output "Unlock Phone (manual step required)"
    Start-Sleep -Seconds 3

    # Scan for open ports
    $Scan_Start = Get-Date
    Write-Output "Scan Started at $($Scan_Start.ToString('t'))"
    Write-Output "Scanning Ports, this may take some time"
    $NmapOutput = nmap -p 30000-49999 -T5 -v $Phone_IP | Tee-Object -Variable NMAP
    $Scan_Stop = Get-Date
    $Scan_Time = New-TimeSpan -Start $Scan_Start -End $Scan_Stop
    Write-Output "Scan took $($Scan_Time.TotalMinutes) minutes"

    # Check if any open ports were found
    if ($NMAP -match "(0 hosts up)") {
        Write-Output "No open ports found, or phone not found"
        Write-Output "Is the host on the same network with Wireless Debugging turned on?"
        Pause
    }

    # Extract open ports from NMAP output
    $Ports = Select-String -InputObject $NMAP -Pattern "\d+/tcp open" -AllMatches | ForEach-Object { $_.Matches.Value -replace "/tcp open" }
    if ($Ports -eq $null) {
        Write-Output "Unexpected issue. Check phone connectivity."
        Pause
    }

    # Split ports into separate variables
    $Ports = $Ports -split [Environment]::NewLine
    $Port1, $Port2, $Port3, $Port4, $Port5 = $Ports

} Until ($Ports.Count -gt 0)  # Ensure we have at least one port

# Initialize a variable to hold the successful port
$GoodPort = $null

# Try connecting to each port
foreach ($Port in @($Port1, $Port2, $Port3, $Port4, $Port5)) {
    Write-Output "Trying port $Port"
    .\adb.exe disconnect "${Phone_IP}:${Port}" | Out-Null
    $ConnectionResult = .\adb.exe connect "${Phone_IP}:${Port}"

    if ($ConnectionResult -match "connected to" -or $ConnectionResult -match "already connected to") {
        $GoodPort = $Port
        Write-Output "Successfully connected to port $Port"
        break
    } else {
        Write-Output "Failed to connect to port $Port"
    }
}

if (-not $GoodPort) {
    Write-Output "***** All ports failed. Trying to pair. *****"
    Write-Output "Current ports: $Port1, $Port2, $Port3, $Port4, $Port5"

    # Pair the device if necessary
    Do {
        $Pair_Code = Read-Host -Prompt "Enter Wi-Fi Pairing Code"
        $Pair_Port = Read-Host -Prompt "Enter Pairing Port"
        $PairResult = .\adb.exe pair "${Phone_IP}:${Pair_Port}" $Pair_Code

        if ($PairResult -match "Failed: Wrong password or connection was dropped." -or
            $PairResult -match "Failed to parse address for pairing" -or
            $PairResult -match "failed to connect to" -or
            $PairResult -match "Failed: Unable to start pairing client.") {
            Write-Output "***** Wrong Wi-Fi Pairing Code or Pairing Port *****"
        }
    } Until ($PairResult -match "Successfully paired to")

    # Retry connecting after pairing
    foreach ($Port in @($Port1, $Port2, $Port3, $Port4, $Port5)) {
        Write-Output "Trying port $Port after pairing"
        .\adb.exe disconnect "${Phone_IP}:${Port}" | Out-Null
        $ConnectionResult = .\adb.exe connect "${Phone_IP}:${Port}"

        if ($ConnectionResult -match "connected to" -or $ConnectionResult -match "already connected to") {
            $GoodPort = $Port
            Write-Output "Successfully connected to port $Port"
            break
        } else {
            Write-Output "Failed to connect to port $Port"
        }
    }
}

if (-not $GoodPort) {
    Write-Output "Issue with found ports. Check Wireless Debugging and restart."
    Exit
}

# Clean up connection status
$GoodPort = $GoodPort -replace "connected to ${Phone_IP}:", ""
$GoodPort = $GoodPort -replace "already connected to ${Phone_IP}:", ""

Write-Output "ADB is connected to ${Phone_IP}:${GoodPort}"
Write-Output "The connection will remain open. No disconnect command issued."
