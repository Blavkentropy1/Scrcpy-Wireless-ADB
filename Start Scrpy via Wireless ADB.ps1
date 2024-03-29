<#  Requires      : SCRCPY and .\adb.exe (.\adb.exe is included in SCRCPY Files)
    Scrcpy Site   : https://github.com/Genymobile/scrcpy
    Description   : Wirelessly connect ADB to device, and Pair ADB if required #>
    
"Start Scrcpy via Wireless ADB"
#=========================[ BEGIN:Parameters  ]============================
$Scrpy_Location = "C:/Scrpy"                           #Needs to Be Updated
$Phone_IP = "192.168.xxx.xxx"                           #IP Needs to be Changed
$Arg0 = "-Sw"                                           #Turn Screen Off
$Arg1 = "--power-off-on-close"                          #Turns Screen off when Closed
$Arg2 = "--stay-awake"						  #Stay Awake	
#=========================[  END:Parameters   ]============================
<#
#Manual Input - Set the following if you want to Manually set SCRPY Parameter
new-variable -name Scrpy_Location -force -value (Read-Host -Prompt "Where is SCRCPY?")
new-variable -name Phone_IP -force -value (Read-Host -Prompt "Phone IP")
#>
cd $Scrpy_Location
Do  {
    new-variable -name Port -force -value (Read-Host -Prompt "Connect Port")
    $Output = .\adb.exe connect ${Phone_IP}:${port} 
    if ($Output -match "failed to connect to" -or $Output -match "no host") 
        {
            "*****ADB Needs to Pair*****"
            do
              {
                new-variable -name Pair_Code -force  -value (Read-Host -Prompt "Wifi Pairing code")
                new-variable -name Pair_Port -force  -value (Read-Host -Prompt "Pair Port")
                $Output_Pair = .\adb.exe pair ${Phone_IP}:${Pair_Port} $Pair_Code
                    if ($Output_pair -match "Failed: Wrong password or connection was dropped." -or $Output_pair -match "Failed to parse address for pairing" -or $output_pair -match "failed to connect to" -or $Output_pair -match "Failed: Unable to start pairing client.") 
                    {
                       "*****Wrong Wifi Pairing code, or Pair Port*****"
                    }
              }
            Until ($Output_pair -match "Successfully paired to")
                    "Device Paired"   
                    $output = .\adb.exe connect ${Phone_IP}:${Port} 
       }
    if ($Output -match "10061" -or $Output -match "bad port number") 
        {
        "*****Incorrect Port Input*****"
        }
    }
Until($Output -match "connected to")
"Scrcpy is Starting"
.\scrcpy.exe --tcpip=${Phone_IP}:${Port} ${Arg0} ${Arg1}
.\adb.exe disconnect ${Phone_IP}:${Port}
