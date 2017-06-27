[System.Collections.ArrayList]$installed_successfully = @( )
[System.Collections.ArrayList]$install_failed = @( )

function Set-VelaWorkspaceConfiguration(
  $Apps, 
  $WindowsFeatures, 
  $RemoteFiles, 
  $PipPackages, 
  $CygwinPackages,
  $Paths,
  $PostInstallMessage) {
  Install-Apps -Apps $Apps
  Install-WinFeatures -Features $WindowsFeatures
  Get-RemoteFiles -Remote_Files $RemoteFiles
  Install-PipPackages -Packages $PipPackages
  Install-CygwinPackages -Packages $CygwinPackages
  Add-Paths -Paths $Paths
  Show-Report
  Write-Host $PostInstallMessage
}

function Install-Apps($Apps) {
  Install-Chocolatey
  foreach ($app in $Apps) {
    choco install $app -y
    Push-Status -item $app
  }
}

function Install-Chocolatey() {
  if(-Not (Get-Command choco -errorAction SilentlyContinue)) {
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  }
}

function Install-WinFeatures($Features) {
  foreach ($feature in $windows_features) {
    Install-WindowsFeature $feature
    Push-Status -item $feature
  }
}

function Install-PipPackages($Packages) {
  Install-Python
  foreach ($package in $Packages) {
    pip3 install $package
    Push-Status -item "Pip - $package"
  }
}

function Install-Python() {
  if(-Not (Get-Command pip3 -ErrorAction SilentlyContinue)) {
    Install-Chocolatey
    choco install python -y
  }
}

function Install-CygwinPackages ($Packages) {
  Install-Cygwin
  foreach ($package in $Packages) {
    cmd /c C:\tools\cygwin\bin\bash.exe --login -c "/usr/bin/apt-cyg install $package"
    Push-Status -item "Cygwin - $package"
  }
}

function Install-Cygwin() {
  if (-Not (Test-Path C:\tools\cygwin\bin\bash.exe)) {
    choco install cygwin -y
  }
  if (-Not (Test-Path C:\tools\cygwin\bin\apt-cyg)) {
    Get-RemoteFile("https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg",
                   "C:\tools\cygwin\bin\apt-cyg")
  }
}

function Get-RemoteFiles($Remote_Files) {
  foreach ($remote_file in $Remote_Files.GetEnumerator()) {
    if (-Not (Test-Path $remote_file.Value)) {
      Get-RemoteFile -Source $remote_file.Name.toString() -Destination $remote_file.Value
    } else {
      Write-Host $remote_file.Name.toString() " is already installed."
    }
    Push-Status -item $remote_file.Name
  }
}

function Get-RemoteFile($Source, $Destination) {
  Write-Host "Downloading $source to $destination"
    try {
      (New-Object System.Net.WebClient).DownloadFile($source, $destination)
    } catch {
      write-error $_.Exception
      $LASTEXITCODE = 1
    }
}

function Add-Paths($Paths) {
  foreach ($path in $Paths) {
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

function Push-Status($item) {
  if($LASTEXITCODE -eq 0) {
    $installed_successfully.add($item)
  } else {
    $install_failed.add($item)
  }
}

function Show-Report() {
  Write-Host "`n########## Vela Configuration Report##########"
  if($installed_successfully.count -gt 0) {
    $successful_installs = ($installed_successfully -join "`n")
    Write-Host "Successfully installed:`n$successful_installs"
  }
  if($install_failed -gt 0) {
    $failed_installs = ($install_failed -join "`n")
    Write-Warning "Installs which failed:`n$failed_installs"
  }
}