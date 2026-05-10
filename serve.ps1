$port = 3000
$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$port"
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response
    $path = $req.Url.LocalPath -replace '/', '\'
    if ($path -eq '\') { $path = '\index.html' }
    $file = Join-Path $root $path.TrimStart('\')
    if (Test-Path $file -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($file)
        $mime = @{'.html'='text/html';'.css'='text/css';'.js'='application/javascript';
                  '.png'='image/png';'.jpg'='image/jpeg';'.svg'='image/svg+xml';
                  '.ico'='image/x-icon';'.json'='application/json'}[$ext]
        if (-not $mime) { $mime = 'application/octet-stream' }
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $res.ContentType = $mime
        $res.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate")
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $res.StatusCode = 404
    }
    $res.OutputStream.Close()
}
