$ErrorActionPreference = 'Stop'

$port = 54321
$sshHost = 'SASAME-shell'
$listenerScript = Join-Path $PSScriptRoot 'vscode-listener.ps1'

$listenerJob = $null

function Test-Port {
  param(
    [string]$HostName,
    [int]$Port
  )

  try {
    $client = [System.Net.Sockets.TcpClient]::new()
    $client.Connect($HostName, $Port)
    $client.Close()

    return $true
  }
  catch {
    return $false
  }
}

try {
  Write-Host "Starting VS Code listener..."

  $listenerJob = Start-Job -FilePath $listenerScript

  for ($i = 0; $i -lt 50; $i++) {
    if (Test-Port '127.0.0.1' $port) {
      break
    }

    if ($listenerJob.State -eq 'Failed') {
      Receive-Job $listenerJob
      throw 'VS Code listener failed to start.'
    }

    Start-Sleep -Milliseconds 100
  }

  if (-not (Test-Port '127.0.0.1' $port)) {
    Receive-Job $listenerJob
    throw "VS Code listener did not open port $port."
  }

  Write-Host "VS Code listener ready."
  Write-Host "Starting SSH RemoteForward: $sshHost"
  Write-Host "Stop with Ctrl+C"
  Write-Host ""

  & "$env:WINDIR\System32\OpenSSH\ssh.exe" `
    -o ExitOnForwardFailure=yes `
    -N `
    $sshHost
}
finally {
  if ($listenerJob) {
    Write-Host ""
    Write-Host "Stopping VS Code listener..."

    Stop-Job $listenerJob -ErrorAction SilentlyContinue
    Remove-Job $listenerJob -Force -ErrorAction SilentlyContinue
  }
}
