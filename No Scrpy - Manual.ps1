<# 
    Requires: .\adb.exe and .\scrcpy.exe (paths to be provided as arguments) and NMAP
    Assumption: NMAP is set as an environmental variable
    Description: Wirelessly connect ADB to a device and pair ADB if required
#>

param (
    [string]$AdbLocation = "D:\Misc Programs\Scrcpy\adb.exe",    # Path to adb executable
    [string]$ScrcpyLocation = "D:\Misc Programs\Scrcpy\scrcpy.exe", # Path to scrcpy executable
    [string]$Phone_IP = "192.168.0.101"   # Update to your phone's IP address
)

# =========================[ Start Script ]===========================

Do {
    # Prompt user to enter the connection port
    $Port = Read-Host -Prompt "Enter the Connect Port"

    # Attempt to connect to the device via ADB
    $Output = & $AdbLocation connect "${Phone_IP}:${Port}"
    
    if ($Output -match "failed to connect to" -or $Output -match "no host") {
        Write-Output "***** ADB Needs to Pair *****"
        
        do {
            # Prompt user for Wi-Fi pairing code and port
            $Pair_Code = Read-Host -Prompt "Enter Wi-Fi Pairing Code"
            $Pair_Port = Read-Host -Prompt "Enter Pairing Port"
            
            # Attempt to pair the device
            $Output_Pair = & $AdbLocation pair "${Phone_IP}:${Pair_Port}" $Pair_Code
            
            if ($Output_Pair -match "Failed: Wrong password or connection was dropped." -or 
                $Output_Pair -match "Failed to parse address for pairing" -or 
                $Output_Pair -match "failed to connect to" -or 
                $Output_Pair -match "Failed: Unable to start pairing client.") {
                Write-Output "***** Wrong Wi-Fi Pairing Code or Pairing Port *****"
            }
        } Until ($Output_Pair -match "Successfully paired to")
        
        Write-Output "Device Paired"
        
        # Retry connecting to the device
        $Output = & $AdbLocation connect "${Phone_IP}:${Port}"
    }
    
    if ($Output -match "10061" -or $Output -match "bad port number") {
        Write-Output "***** Incorrect Port Input *****"
    }
} Until ($Output -match "connected to")

Write-Output "ADB is Connected and will remain open"
