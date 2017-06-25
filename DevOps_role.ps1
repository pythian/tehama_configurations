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
  "nodejs",
  "yarn",
  "cygwin",
  "superputty",
  "grepwin",
  "jq",
  "wget",
  "curl",
  "webstorm",
  "googlechrome",
  "virtualbox",  # Only supports 32-bit hosts on workspaces
  "docker",
  "docker-machine",
  "docker-compose",
  "vagrant"
)
[System.Collections.ArrayList]$installed_successfully = @( )
[System.Collections.ArrayList]$install_failed = @( ) 

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
  "C:\Program Files (x86)\Microsoft VS Code\bin"
)

function Configure-Vela-Workspace() {
  Install-Chocolatey
  Install-Apps
  Add-Paths
  Final-Report
}

function Install-Chocolatey() {
  if(-Not (Get-Command choco -errorAction SilentlyContinue)) {
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  }
}

function Install-Apps() {
  foreach ($app in $apps) {
    choco install $app -y
    Trap-Status
  }
}

function Add-Paths() {
  foreach ($path in $paths) {
    Add-Path -Path $path
  }
}

function Add-Path($Path) {
  [System.Collections.ArrayList]$EnvPaths = $env:Path -split ";"
  if($EnvPaths -notcontains $Path) {
    $env:Path += ";$Path"
    [Environment]::SetEnvironmentVariable("Path", $env:Path,[System.EnvironmentVariableTarget]::User)
    Write-Host "Added $path to PATH."
  }
}

function Trap-Status() {
  if($LASTEXITCODE -eq 0) {
    $installed_successfully.add($app)
  } else {
    $install_failed.add($app)
  }
}

function Final-Report() {
  if($installed_successfully.count -gt 0) {
    Write-Host "Successfully installed:`n" ($installed_successfully -join "`n")
  }
  if($install_failed -gt 0) {
    Write-Host "Installs which failed:`n" ($install_failed -join "`n")
  }
}

Configure-Vela-Workspace
