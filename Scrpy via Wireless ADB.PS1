<#  Program       : Scrcpy 
    Scrcpy Site   : https://github.com/Genymobile/scrcpy
    File          : Scrcpy.ps1
    Description   : Wirelessly connect ADB to device, and Pair ADB if required
    ADB           : This script assumes this is set as a Enviromental variable, 
                    or abd.exe is located in the Scrpy Location #>
                    
Write-Output -InputObject "Start Scrcpy via Wireless ADB"

#=========================[ BEGIN:Parameters  ]============================
#Needs to be Set
$Scrpy_Location = "C:\Scrcpy\scrcpy-win64-v1.24\"
$Phone_IP = "192.168.0.xxx"
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
        adb connect ${Phone_IP}:${port}
        Write-Output -InputObject "Succesfully Connected, starting Scrcpy"
        scrcpy.exe --turn-screen-off
        }
Else {
       Write-Output -InputObject "Succesfully Connected, starting Scrcpy"
       scrcpy.exe --turn-screen-off
       }
adb disconnect ${Phone_IP}:${port}
