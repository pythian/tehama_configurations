<#
Requirements:
1. Right click powershell and run as administrator.  
2. In powershell, Get-ExecutionPolicy should not be set to "Restricted".  If it is
run "Set-ExecutionPolicy Bypass" first.
3. cd into containing directory and run script with .\DevOps_role.ps1
#>

# Searchable list of apps available by running 'choco search <packagename>'
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
  "virtualbox",  # Only supports 32-bit guests on workspaces
  "docker",
  "docker-machine",
  "docker-compose",
  "vagrant"
)

# Searchable list of windows features available by running 'Get-WindowsFeature'
$windows_features = @(
  "Telnet-Client"
) 

$remote_files = @{
  "https://downloads.dcos.io/binaries/cli/windows/x86-64/dcos-1.9/dcos.exe" = "C:\ProgramData\chocolatey\bin\dcos.exe"
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
  "C:\Program Files (x86)\Microsoft VS Code\bin"
)

[System.Collections.ArrayList]$installed_successfully = @( )
[System.Collections.ArrayList]$install_failed = @( )

function Configure-Vela-Workspace() {
  Install-Chocolatey
  Install-Apps
  Install-WinFeatures
  Download-Files
  Add-Paths
  Show-Report
}

function Install-Chocolatey() {
  if(-Not (Get-Command choco -errorAction SilentlyContinue)) {
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  }
}

function Install-Apps() {
  foreach ($app in $apps) {
    choco install $app -y
    Trap-Status -item $app
  }
}

function Install-WinFeatures() {
  foreach ($feature in $windows_features) {
    Install-WindowsFeature $feature
    Trap-Status -item $feature
  }
}

function Download-Files() {
  foreach ($remote_file in $remote_files.GetEnumerator()) {
    if (-Not (Test-Path $remote_file.Value)) {
      Download-File -Source $remote_file.Name.toString() -Destination $remote_file.Value
    }
    Trap-Status -item $remote_file.Name
  }
}

function Download-File($Source, $Destination) {
  Write-Host "Downloading $source to $destination"
    try {
      (New-Object System.Net.WebClient).DownloadFile($source, $destination)
    } catch {
      write-error $_.Exception
      $LASTEXITCODE = 1
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

function Trap-Status($item) {
  if($LASTEXITCODE -eq 0) {
    $installed_successfully.add($item)
  } else {
    $install_failed.add($item)
  }
}

function Show-Report() {
  Write-Host "########## Vela Configuration Report##########"
  if($installed_successfully.count -gt 0) {
    Write-Host "Successfully installed:`n" ($installed_successfully -join "`n")
  }
  if($install_failed -gt 0) {
    Write-Host "Installs which failed:`n" ($install_failed -join "`n")
  }
}

Configure-Vela-Workspace
