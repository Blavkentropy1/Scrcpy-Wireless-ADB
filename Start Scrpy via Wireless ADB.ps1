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

Write-Output -InputObject (adb connect ${Phone_IP}:${port} ) -OutVariable Output
 
if ($Output -match "failed" -or $Output -match "no host") 
        {
        Write-Output -InputObject "Unable to connect, attempting to Pair Phone"
        new-variable -name Pair_Port -value (Read-Host -Prompt "Pair Port")
        new-variable -name Pair_Code -value (Read-Host -Prompt "Pair Code")
        adb pair ${Phone_IP}:${Pair_Port} $Pair_Code 
        Write-Output -InputObject "Succesfully Paired, Connecting ADB"
        adb connect ${Phone_IP}:${port}
        Write-Output -InputObject "Succesfully Connected, starting Scrcpy"
        scrcpy.exe --turn-screen-off
        }
Else {
       Write-Output -InputObject "Succesfully Connected, starting Scrcpy"
       scrcpy.exe --turn-screen-off
       }
       
adb disconnect ${Phone_IP}:${port}
