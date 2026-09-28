$ErrorActionPreference = 'Stop'

$port = 54321
$prefix = "http://localhost:$port/"

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($prefix)

try {
  $listener.Start()

  Write-Host "VS Code listener started: $prefix"
  Write-Host "Stop with Ctrl+C"

  while ($listener.IsListening) {
    $contextTask = $listener.GetContextAsync()

    while (-not $contextTask.Wait(200)) {
      # Ctrl+Cを受け取れるよう定期的に待機を抜ける
    }

    $context = $contextTask.GetAwaiter().GetResult()
    $response = $context.Response

    try {
      $hostName = $context.Request.QueryString['host']
      $path = $context.Request.QueryString['path']

      Write-Host "request: host='$hostName' path='$path'"

      if (-not $hostName -or -not $path) {
        $response.StatusCode = 400
        continue
      }

      Write-Host "exec: code --new-window --remote ssh-remote+$hostName $path"

      & code `
        --new-window `
        --remote "ssh-remote+$hostName" `
        $path

      $response.StatusCode = 204
    }
    catch {
      Write-Host "ERROR: $_"
      $response.StatusCode = 500
    }
    finally {
      $response.Close()
    }
  }
}
finally {
  if ($listener.IsListening) {
    $listener.Stop()
  }

  $listener.Close()

  Write-Host "VS Code listener stopped."
}
