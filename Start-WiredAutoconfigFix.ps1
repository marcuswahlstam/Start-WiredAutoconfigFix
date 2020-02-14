# Path to SetupCompleteTemplate.cmd, default is $env:WINDIR\CCM\SetupCompleteTemplate.cmd
$SetupCompleteTemplate = "$env:WINDIR\CCM\SetupCompleteTemplate.cmd"

# String to search for in $SetupCompleteTemplate to find where we should put our customizations
# Escape backslash (\) with another backslash (\\)
$TemplateSearchString = "%SCCMClientPath%\\TSMBootstrap.exe"

# Get the content of $SetupCompleteTemplate
$TemplateContent = Get-Content $SetupCompleteTemplate

# Get row number of $TemplateSearchString
$SearchStringRow = ($TemplateContent | Select-String "$TemplateSearchString")[0].LineNumber

# Get number of total rows in $TemplateContent
$TotalRows = $TemplateContent.Count

# Get the part of $TemplateContent that is before $TemplateSearchString
$FirstPart = $TemplateContent | Select-Object -First $($SearchStringRow-1)

# Get the part of $TemplateContent that is after $TemplateSearchString, including $TemplateSearchString
$LastPart = $TemplateContent | Select-Object -Index ($($SearchStringRow-1)..$TotalRows)

# Define the customization part to insert into $SetupCompleteTemplate
# If your network connections are not named "Ethernet", change the Get-NetAdapter filter in the content below
$CustomPart = (
"echo --- Running 802.1x Fixes ---",
"echo %DATE%-%TIME% `"Custom Configuration`" >> %WINDIR%\setupcomplete.log",
"echo %DATE%-%TIME% `"Disabling NetAdapter for 5 seconds`" >> %windir%\setupcomplete.log",
"echo Disabling NetAdapter for 5 seconds",
"powershell.exe -command `"Get-NetAdapter *eth* | Disable-NetAdapter -Confirm:`$false -PassThru -Verbose`" >> %WINDIR%\setupcomplete.log",
"powershell.exe -command `"Start-Sleep 5`"",

"echo %DATE%-%TIME% `"Enabling NetAdapter and sleeping for 15 seconds`" >> %windir%\setupcomplete.log",
"echo Enabling NetAdapter and waits 15 seconds",
"powershell.exe -command `"Get-NetAdapter *eth* | Enable-NetAdapter -Confirm:`$false -PassThru -Verbose`" >> %WINDIR%\setupcomplete.log",
"powershell.exe -command `"Start-Sleep 15`"",

"echo %DATE%-%TIME% `"Restarting Wired Autoconfig Services`" >> %WINDIR%\setupcomplete.log",
"echo Restarting dot3svc and waits 15 seconds",
"powershell.exe -command `"restart-service dot3svc -PassThru -verbose`" >> %WINDIR%\setupcomplete.log",
"powershell.exe -command `"Start-Sleep 15`"",

"ipconfig >> %WINDIR%\setupcomplete.log",
"netsh lan show interfaces >> %WINDIR%\setupcomplete.log",
"netsh lan show Profiles >> %WINDIR%\setupcomplete.log",
"echo --- Done running 802.1x Fixes ---",
"echo Resuming Task Sequence",
""
)

# Create a new and modified $SetupCompleteTemplate
Set-Content $SetupCompleteTemplate -Value $FirstPart,$CustomPart,$LastPart
