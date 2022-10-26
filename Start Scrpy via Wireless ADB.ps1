<#  
    Requires      : SCRCPY and ADB.exe (ADB.EXE is included in SCRCPY Files)
    Scrcpy Site   : https://github.com/Genymobile/scrcpy
    Description   : Wirelessly connect ADB to device, and Pair ADB if required
#>
                    
Write-Output -InputObject "Start Scrcpy via Wireless ADB"

#=========================[ BEGIN:Parameters  ]============================
$Scrpy_Location = "D:\Scrcpy\scrcpy-win64-v1.24""
#=========================[  END:Parameters   ]============================

#.\adb.exe disconnect
cd $Scrpy_Location

do  {
new-variable -name Phone_IP -force -value (Read-Host -Prompt "Phone IP")
new-variable -name Port -force -value (Read-Host -Prompt "Connect Port")
Write-Output -InputObject (.\adb.exe connect ${Phone_IP}:${port} ) -OutVariable Output


if ($Output -match "failed" -or $Output -match "no host") 
        {
            Write-Output -InputObject "Unable to connect, attempting to Pair Phone"
            new-variable -name Pair_Code -force -value (Read-Host -Prompt "Pair Code")
            new-variable -name Pair_Port -force -value (Read-Host -Prompt "Pair Port")
            Write-Output -InputObject ( .\adb.exe pair ${Phone_IP}:${Pair_Port} $Pair_Code ) -OutVariable Output_Pair
            if ($Output_pair -match "Failed: Wrong password or connection was dropped." -or $Output_pair -match "Failed to parse address for pairing" -or $output_pair -match "failed to connect to" -or $Output_pair -match "Failed: Unable to start pairing client.") 
                    {
                       Write-Output -InputObject "Wrong Pair Pin, or Pair Port - Restarting"            
                     }   
            if ($Output_pair -match "Successfully paired to") 
                    {
                    Write-Output -InputObject "Device Paired"   
                    Write-Output -InputObject (.\adb.exe connect ${Phone_IP}:${port} ) -OutVariable Output         
                    }   
         }


if ($Output -match "10061" -or $Output -match "bad port number") 
        {
        Write-Output -InputObject "Check the Port is Correct"
        }
    }
        

Until($Output -match "connected to")
Write-Output -InputObject "SCRPY Starting"

#.\scrcpy.exe --tcpip=${Phone_IP}:${Port} --turn-screen-off --power-off-on-close
