# Start-WiredAutoconfigFix
Having problems with 802.1x in Windows 10 Inplace-upgrade? This script is for you!

Just run the script in you Task Sequence ahead of the Upgrade Operating System step.

The script inserts a few commands to SetupCompleteTemplate.cmd so the computer is able to authenticate with it's machine certificate.

If it doesn't work, try to increase the time of the first Start-Sleep (after the Disable-NetAdapter command). The default in this script is 5 seconds. 

If you have CM 1902 or later, you can just copy/paste the script in the Run Powershell Command step.
