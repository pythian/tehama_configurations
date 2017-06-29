[System.Collections.ArrayList]$installed_successfully = @( )
[System.Collections.ArrayList]$install_failed = @( )

function Set-VelaWorkspaceConfiguration(
  $Apps, 
  $WindowsFeatures, 
  $RemoteFiles, 
  $PipPackages, 
  $CygwinPackages,
  $GitRepos,
  $Paths) {
  Install-Apps -Apps $Apps
  Install-WinFeatures -Features $WindowsFeatures
  Get-RemoteFiles -Remote_Files $RemoteFiles
  Install-PipPackages -Packages $PipPackages
  Install-CygwinPackages -Packages $CygwinPackages
  Install-GitRepos -Repos $GitRepos
  Add-Paths -Paths $Paths
  Show-Report
}

function Install-Apps($Apps) {
  Install-Chocolatey
  foreach ($app in $Apps) {
    Install-App -app $app
    Push-Status -item "Choco - $app"
  }
}

function Install-App($app) {
  if ($app.GetType().Name -eq "Hashtable") {
    if (-Not($app.checksum -eq $null)) {
      $checksum = "--checksum $($app.checksum)"
    }
    if (-Not($app.version -eq $null)) {
      $version = "--version $($app.version)"
    }
    Invoke-Expression("choco install $($app.name) $version $checksum -y")
  } else {
    choco install $app -y
  }
}

function Install-Chocolatey() {
  if(-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  }
}

function Install-WinFeatures($Features) {
  foreach ($feature in $windows_features) {
    Add-WindowsFeature $feature
    Push-Status -item "Windows Feature - $feature"
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
    Push-Status "Choco - python"
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
    Push-Status "Choco - cygwin"
  }
  if (-Not (Test-Path C:\tools\cygwin\bin\apt-cyg)) {
    Get-RemoteFile -Source "https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg" -Destination "C:\tools\cygwin\bin\apt-cyg"
    Push-Status "Remote - apt-cyg"
  }
}

function Install-GitRepos($Repos) {
  Install-Git
  foreach ($repo in $Repos.GetEnumerator()) {
    $repo_url = $repo.Name.toString()
    Install-GitRepo -source $repo_url -destination $repo.Value.toString()
    Push-Status "Git - $repo_url"
  }
}

function Install-GitRepo($source, $destination) {
  if (-Not (Test-Path $destination)) {
    Write-Host "Cloning repo $source"
    git clone $source $destination
  } else {
    Write-Host "$source already exists locally at $destination"
  }
}

function Install-Git() {
  if (-Not (Get-Command git -ErrorAction SilentlyContinue)) {
    choco install git -y
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
  Write-Host "Downloading $Source to $Destination"
    try {
      (New-Object System.Net.WebClient).DownloadFile($Source, $Destination)
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