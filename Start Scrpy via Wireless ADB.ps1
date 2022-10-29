<#  Requires      : SCRCPY and ADB.exe (ADB.EXE is included in SCRCPY Files)
    Scrcpy Site   : https://github.com/Genymobile/scrcpy
    Description   : Wirelessly connect ADB to device, and Pair ADB if required #>
    
Write-Output -InputObject "Start Scrcpy via Wireless ADB"
#=========================[ BEGIN:Parameters  ]============================
$Scrpy_Location = "D:\Scrcpy\scrcpy-win64-v1.24"                #Needs to Be Updated
$Phone_IP = "192.168.0.xxx"                             #IP Needs to be Changed
$Arg0 = "-Sw"                                           #Turn Screen Off
$Arg1 = "--power-off-on-close"                          #Turns Screen off when Closed
#=========================[  END:Parameters   ]============================
<#
#Set the following if you want to Manually set SCRPY Parameter
new-variable -name Scrpy_Location -force -value (Read-Host -Prompt "Where is SCRCPY?")
new-variable -name Phone_IP -force -value (Read-Host -Prompt "Phone IP")
#>
cd $Scrpy_Location
Do  {
    new-variable -name Port -force -value (Read-Host -Prompt "Connect Port")
    $Output = .\adb.exe connect ${Phone_IP}:${port} 
    if ($Output -match "failed to connect to" -or $Output -match "no host") 
        {
            Write-Output -InputObject "*****ADB Needs to Pair*****"
            do
            {
                new-variable -name Pair_Code -force  -value (Read-Host -Prompt "Wifi Pairing code")
                new-variable -name Pair_Port -force  -value (Read-Host -Prompt "Pair Port")
                $Output_Pair = .\adb.exe pair ${Phone_IP}:${Pair_Port} $Pair_Code
                    if ($Output_pair -match "Failed: Wrong password or connection was dropped." -or $Output_pair -match "Failed to parse address for pairing" -or $output_pair -match "failed to connect to" -or $Output_pair -match "Failed: Unable to start pairing client.") 
                    {
                       Write-Output -InputObject "*****Wrong Wifi Pairing code, or Pair Port*****"
                    }
            }
            Until ($Output_pair -match "Successfully paired to")
                    Write-Output -InputObject "Device Paired"   
                    $output = .\adb.exe connect ${Phone_IP}:${Port}
         }
    if ($Output -match "10061" -or $Output -match "bad port number") 
        {
        Write-Output -InputObject "*****Incorrect Port Input*****"
        }
    }
Until($Output -match "connected to")
Write-Output -InputObject "Scrcpy is Starting"
.\scrcpy.exe --tcpip=${Phone_IP}:${Port} ${Arg0} ${Arg1}
.\adb.exe disconnect ${Phone_IP}:${Port}
