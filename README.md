## Getting Started:
1. Add firewall rule "0.0.0.0/0" to the list of rules in the workspace agent.
2. Right click powershell and run as administrator.  
3. In powershell, Get-ExecutionPolicy should not be set to "Restricted".  If it is
run "Set-ExecutionPolicy Bypass" first.
4. Copy, paste, and run this in the terminal: 
iex((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/pythian/tehama_configurations/master/DevOps_role.ps1')) 

or substitute url for the role desired.
