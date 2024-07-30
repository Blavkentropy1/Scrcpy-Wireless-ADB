<# 
    Requires: SCRCPY and .\adb.exe (included in SCRCPY files)
    Scrcpy Site: https://github.com/Genymobile/scrcpy
    Description: Wirelessly connect ADB to a device and pair ADB if required
#>

# Start Scrcpy via Wireless ADB
# =========================[ BEGIN:Parameters ]===========================
$Scrcpy_Location = "D:\Misc Programs\Scrcpy\"   # Update to the location of your Scrcpy
$Phone_IP = "192.168.0.101"                    # Update to your phone's IP address
$Arg0 = "-Sw"                                  # Turn screen off
$Arg1 = "--power-off-on-close"                 # Turns screen off when closed
$Arg2 = "--stay-awake"                         # Keep device awake
# =========================[ END:Parameters ]===========================

# Change directory to the location of Scrcpy
cd $Scrcpy_Location

Do {
    # Prompt user to enter the connection port
    $Port = Read-Host -Prompt "Enter the Connect Port"

    # Attempt to connect to the device via ADB
    $Output = .\adb.exe connect "${Phone_IP}:${Port}"
    
    if ($Output -match "failed to connect to" -or $Output -match "no host") {
        Write-Output "***** ADB Needs to Pair *****"
        
        do {
            # Prompt user for Wi-Fi pairing code and port
            $Pair_Code = Read-Host -Prompt "Enter Wi-Fi Pairing Code"
            $Pair_Port = Read-Host -Prompt "Enter Pairing Port"
            
            # Attempt to pair the device
            $Output_Pair = .\adb.exe pair "${Phone_IP}:${Pair_Port}" $Pair_Code
            
            if ($Output_Pair -match "Failed: Wrong password or connection was dropped." -or 
                $Output_Pair -match "Failed to parse address for pairing" -or 
                $Output_Pair -match "failed to connect to" -or 
                $Output_Pair -match "Failed: Unable to start pairing client.") {
                Write-Output "***** Wrong Wi-Fi Pairing Code or Pairing Port *****"
            }
        } Until ($Output_Pair -match "Successfully paired to")
        
        Write-Output "Device Paired"
        
        # Retry connecting to the device
        $Output = .\adb.exe connect "${Phone_IP}:${Port}"
    }
    
    if ($Output -match "10061" -or $Output -match "bad port number") {
        Write-Output "***** Incorrect Port Input *****"
    }
} Until ($Output -match "connected to")

Write-Output "Scrcpy is Starting"
.\scrcpy.exe --tcpip=${Phone_IP}:${Port} $Arg0 $Arg1 $Arg2

# Disconnect ADB after starting Scrcpy
.\adb.exe disconnect ${Phone_IP}:${Port}
