<#  Requires      : SCRCPY and ADB.exe (ADB.EXE is included in SCRCPY Files) and NMAP
    Assumption    : NMAP is set as a Enviromental Variable.
    Scrcpy Site   : https://github.com/Genymobile/scrcpy
    Description   : Wirelessly connect ADB to device, and Pair ADB if required, with NMAP to find the Random Port #>
#=========================[ BEGIN:Parameters  ]============================
$Scrpy_Location = "D:\Scrcpy\scrcpy-win64-v1.24"                #Needs to Be Updated
$Phone_IP = "192.168.0.101"                             #IP Needs to be Changed
$Arg0 = "-Sw"                                           #Turn Screen Off
$Arg1 = "--power-off-on-close"                          #Turns Screen off when SCRCPY Closed
#=========================[  END:Parameters   ]============================
<#
#Set the following if you want to Manually set SCRPY Parameter
new-variable -name Scrpy_Location -value (Read-Host -Prompt "Where is SCRCPY?")
new-variable -name Phone_IP  -value (Read-Host -Prompt "Phone IP")
#>

Do  {
CD $Scrpy_Location
"Unlock Phone"
Sleep 3
$Scan_Start = get-date -format t
"Scan Started at $Scan_Start" 
"Scanning Ports, This will take some time"
nmap -p 30000-49999 -T5 -v  $Phone_IP | Tee-Object -Variable NMAP
$Scan_Stop = get-date -format t
$Scan_Time = New-TimeSpan -Start $Scan_Start -End $Scan_Stop
    If ($NMAP -match "(0 hosts up)" ) 
         { 
         "No Open Ports found, or Phone not found"
         "Is The Host on the same network with Wireless Debugging turned on?"
         Pause
         }
$Port = Select-String -inputobject $NMAP -Pattern "[0-9]+[0-9]+[0-9]+[0-9]+[0-9]/tcp open" -AllMatches | % { $_.Matches.Value } 
If ($Port -notmatch  "/tcp open")
        {
        "Unexpected Issue Check Phone Connectivity"
        Pause
        }
$Port = $Port -replace "/tcp open"
$Port1,$Port2,$Port3,$Port4,$Port5 = $Port -split [Environment]::NewLine
    }

Until ($NMAP -Match "/tcp open") 
"Scan took $Scan_time Minutes"

Do  { 
            "Trying First Found Port $Port1"
            .\adb.exe disconnect ${Phone_IP}:${Port1} | out-null
                $Try1 = .\adb.exe connect ${Phone_IP}:${Port1} 
                      If ($Try1 -match "connected to")
                         {
                         $Good_port = $Try1
                         Break
                         }
                      If ($Try1 -match "Already Connected")
                        {
                         $Good_port = $Try1
                         Break
                        }
                      "Didnt Connect, Trying Next port"

            "Trying Second Found Port $Port2"
            .\adb.exe disconnect ${Phone_IP}:${Port2} | out-null
                $Try2 = .\adb.exe connect ${Phone_IP}:${Port2} 
                      If ($Try2 -match "connected to")
                        {
                        $Good_port = $Try2
                        Break
                        }
                      If ($Try2 -match "already connected to")
                        {
                        $Good_port = $Try2
                        Break
                        }
                      "Didnt Connect, Trying Next port"

            "Trying Third Found Port $Port3"
            .\adb.exe disconnect ${Phone_IP}:${Port3} | out-null
                $Try3 =.\adb.exe connect ${Phone_IP}:${Port3} 
                      If ($Try3 -match "connected to")
                        {
                        $Good_port = $Try3
                        Break
                        }
                      "Didnt Connect, Trying Next port"

             "Trying Fouth Found Port $Port4"
             .\adb.exe disconnect ${Phone_IP}:${Port4} | out-null
                $Try4 = .\adb.exe connect ${Phone_IP}:${Port4} 
                      If ($Try4 -match "connected to")
                        {
                        $Good_port = $Try4
                        Break
                        }
                 "Didnt Connect, Trying Next port"

             "Trying Fith Found Port $Port5"
             .\adb.exe disconnect ${Phone_IP}:${Port5} | out-null
                $Try5 = .\adb.exe connect ${Phone_IP}:${Port5} 
                      If ($Try5 -match "connected to")
                        {
                        $Good_port = $Try5
                        Break
                        }
                      "*****Port Scan is Bad Trying to Pair******"
                      "Current Ports Open $Port1,$Port2,$Port3,$Port4,$Port5"

           If ($Try1,$Try2,$Try3,$Try4,$Try5 -match "failed to connect to" -or $Try1,$Try2,$Try3,$Try4.$Try5 -match "no host") 
            {
               Do
                 {
                new-variable -name Pair_Code -force -value (Read-Host -Prompt "Wifi Pairing code")
                new-variable -name Pair_Port -force -value (Read-Host -Prompt "Pair Port")
                $Output_Pair = .\adb.exe pair ${Phone_IP}:${Pair_Port} $Pair_Code
                
                     If ($Output_pair -match "Failed: Wrong password or connection was dropped." -or $Output_pair -match "Failed to parse address for pairing" -or $output_pair -match "failed to connect to" -or $Output_pair -match "Failed: Unable to start pairing client.") 
                          {
                          "*****Wrong Wifi Pairing code, or Pair Port*****"
                          }
                 } 
                   Until ($Output_pair -match "Successfully paired to") 
             }
             If ($Good_port -Notmatch "connected to" -or $Good_port -Notmatch "already connect to")
                {
                "Issue with Found Ports, Check Wireless Debugging turned on and restart"
                Exit
                }
    }
Until ($Good_port -match "connected to" -or $Good_port -match "already connect to") 

if ($Good_port  -match "already connected to ${Phone_IP}:")
    {
    $Good_port = $Good_port -replace "already connected to ${Phone_IP}:"
    }

if ($Good_port  -match "connected to ${Phone_IP}:")
    {
    $Good_port = $Good_port -replace "connected to ${Phone_IP}:"
    }

"ADB is Connected, Scrcpy is Starting"
.\scrcpy.exe --tcpip=${Phone_IP}:${Good_port} ${Arg0} ${Arg1}  
.\adb.exe disconnect ${Phone_IP}:${Good_port}
