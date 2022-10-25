<#  
    Requires      : SCRCPY and ADB.exe (ADB.EXE is included in SCRCPY Files)
    Scrcpy Site   : https://github.com/Genymobile/scrcpy
    Description   : Wirelessly connect ADB to device, and Pair ADB if required
#>
                    
Write-Output -InputObject "Start Scrcpy via Wireless ADB"

#=========================[ BEGIN:Parameters  ]============================
$Scrpy_Location = "C:\Scrcpy\scrcpy-win64-v1.24\"  #------------Needs a location
$Phone_IP = "192.168.0.xxx"                        #------------Needs a IP
$Port = Read-Host -Prompt "Connect Port"
#=========================[  END:Parameters   ]============================

cd $Scrpy_Location

Write-Output -InputObject (.\adb.exe connect ${Phone_IP}:${port} ) -OutVariable Output
 
if ($Output -match "connected to") 
        {
        Write-Output -InputObject "Succesfully Connected, starting Scrcpy"
        .\scrcpy.exe --turn-screen-off
        exit
        }
if ($Output -match "failed" -or $Output -match "no host") 
        {
        Write-Output -InputObject "Unable to connect, attempting to Pair Phone"
        new-variable -name Pair_Code -force -value (Read-Host -Prompt "Pair Code")
        new-variable -name Pair_Port -force -value (Read-Host -Prompt "Pair Port")
        .\adb.exe pair ${Phone_IP}:${Pair_Port} $Pair_Code 
        Write-Output -InputObject "Succesfully Paired, Connecting ADB"
        .\adb.exe connect ${Phone_IP}:${port}
        Write-Output -InputObject "Succesfully Connected, starting Scrcpy"
        .\scrcpy.exe --turn-screen-off
        Write-Output -InputObject "Scrcpy Has been Closed. Exiting"
        exit
        }
if ($Output -match "cannot connect to") 
        {
        Write-Output -InputObject "Port appears to be Incorrect Exiting"
        Pause
        exit
        }
Else {
       Write-Output -InputObject "Unknown Output, Check error Exiting"
       Pause
       exit
       }
