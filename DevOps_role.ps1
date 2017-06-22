<#
Requirements:
1. Right click powershell and run as administrator.  
2. In powershell, Get-ExecutionPolicy should not be set to "Restricted".  If it is
run "Set-ExecutionPolicy Bypass" first.
3. cd into containing directory and run script with .\DevOps_role.ps1
#>

$apps = @(
  "git",
  "vim",
  "conemu",
  "python",
  "visualstudiocode",
  "sublimetext3",
  "terraform",
  "postman",
  "mysql.workbench",
  "yarn",
  "nodejs",
  "cygwin",
  "superputty",
  "grepwin",
  "jq",
  "wget",
  "curl",
  "webstorm",
  "googlechrome"
)

function Install-Chocolatey {
 iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

function Install-Apps {
  foreach ($app in $apps) {
    choco install $app -y
  }
}

function Configure-Vela-Workspace {
  Install-Chocolatey
  Install-Apps
}

Configure-Vela-Workspace