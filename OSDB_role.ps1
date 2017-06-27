<#
Requirements:
1. Right click powershell and run as administrator.  
2. In powershell, Get-ExecutionPolicy should not be set to "Restricted".  If it is
run "Set-ExecutionPolicy Bypass" first.
3. Copy, paste, and run this in the terminal: 
iex((System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/pythian/vela_configurations/master/OSDB_role.ps1'))
#>
if(Test-Path $PSScriptRoot/modules/Vela-Utils.psm1) {
  Import-Module $PSScriptRoot/modules/Vela-Utils.psm1 -Force
} else {
  Remove-Item ~\AppData\Local\Temp\Vela-Utils.psm1 -ErrorAction SilentlyContinue
  (New-Object System.Net.WebClient).DownloadFile(
    'https://raw.githubusercontent.com/pythian/vela_configurations/master/modules/Vela-Utils.psm1',
    "~\AppData\Local\Temp\Vela-Utils.psm1")
  Import-Module ~\AppData\Local\Temp\Vela-Utils.psm1 -Force
}

# Searchable list of apps available by running 'choco search <packagename>'
$apps = @(
  "visioviewer",
  "Office365ProPlus",
  "7zip",
  "git",
  "vim",
  "conemu",
  "python",
  "visualstudiocode",
  "sublimetext3",
  "mysql.workbench",
  "cygwin",
  "superputty",
  "grepwin",
  "jq",
  "wget",
  "curl",
  "googlechrome",
  "virtualbox",  # Only supports 32-bit guests on workspaces
  "docker",
  "docker-machine",
  "docker-compose",
  "vagrant",
  "slack"
)

# Searchable list of Python packages available by running 'pip3 search <packagename>'
$pip_packages = @(
  "awscli"
)

# Searchable list of windows features available by running 'Get-WindowsFeature'
$windows_features = @(
  "Telnet-Client"
) 

$remote_files = @{
  "https://downloads.dcos.io/binaries/cli/windows/x86-64/dcos-1.9/dcos.exe" = "C:\ProgramData\chocolatey\bin\dcos.exe";
  # Wox is an Alfred equivalent launcher for Windows: Option + Spacebar
  "https://github.com/Wox-launcher/Wox/releases/download/v1.3.424/Wox-1.3.424.exe" = "C:\ProgramData\chocolatey\bin\Wox.exe"
}

# Searchable list of Cygwin packages available at https://cygwin.com/cgi-bin2/package-grep.cgi
# or via cli in Cygwin by 'apt-cyg searchall <packagename>'
$cygwin_packages = @(
  "python2",
  "python-pip",
  "openssl",
  "openssl-devel",  # Required for ansible
  "python-crypto",  # Required for ansible
  "python-openssl", # Required for ansible
  "python-yaml",    # Required for ansible
  "python-jinja2"   # Required for ansible
)

# Ansible client doesn't work on windows outside of cygwin today.
$git_repos = @{
  "https://github.com/ansible/ansible" = "C:\tools\cygwin\opt\ansible"
}

$paths = @(
  "C:\Python36\Scripts\",
  "C:\Python36\",
  "C:\ProgramData\chocolatey\bin",
  "C:\Program Files\Git\cmd",
  "C:\Program Files\Git\usr\bin",
  "C:\Program Files\nodejs\",
  "C:\Program Files (x86)\vim\vim80",
  "C:\Program Files (x86)\Yarn\bin",
  "D:\Users\wayekoxodise\AppData\Local\Yarn\bin",
  "C:\Program Files (x86)\Microsoft VS Code\bin",
  "C:\tools\cygwin\opt\ansible\bin"
)

Set-VelaWorkspaceConfiguration `
  -Apps $apps `
  -WindowsFeatures $windows_features `
  -RemoteFiles $remote_files `
  -PipPackages $pip_packages `
  -CygwinPackages $cygwin_packages `
  -GitRepos $git_repos `
  -Paths $paths `
  -PostInstallMessage "`nRun 'Wox.exe' once to start an Alfred-like launcher."

# Copy ansible libs into cygwin python lib folder
if (-Not (Test-Path C:\tools\cygwin\lib\python2.7\ansible)) {
  Copy-Item C:\tools\cygwin\opt\ansible\lib\* C:\tools\cygwin\lib\python2.7 -Recurse
}
