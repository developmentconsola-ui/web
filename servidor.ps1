# Servidor HTTP Simple para la App de Mantenimiento de Olas
# Este script inicia un servidor web local en el puerto 8000

$port = 8000
$url = "http://localhost:$port"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Servidor Local - App Mantenimiento" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Iniciando servidor en: $url" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANTE:" -ForegroundColor Yellow
Write-Host "- El servidor se iniciará en el puerto $port" -ForegroundColor White
Write-Host "- Abre tu navegador en: $url" -ForegroundColor White
Write-Host "- Presiona Ctrl+C para detener el servidor" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Crear listener HTTP
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("$url/")
$listener.Start()

Write-Host "✓ Servidor iniciado correctamente!" -ForegroundColor Green
Write-Host "✓ Abriendo navegador..." -ForegroundColor Green
Write-Host ""

# Abrir navegador
Start-Process $url

Write-Host "Esperando conexiones... (Presiona Ctrl+C para detener)" -ForegroundColor Cyan
Write-Host ""

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # Obtener ruta del archivo solicitado
        $path = $request.Url.LocalPath
        if ($path -eq "/") { $path = "/index.html" }
        
        $filePath = Join-Path $PSScriptRoot $path.TrimStart('/')
        
        Write-Host "$(Get-Date -Format 'HH:mm:ss') - Solicitud: $path" -ForegroundColor Gray
        
        if (Test-Path $filePath) {
            # Determinar tipo de contenido
            $contentType = switch ([System.IO.Path]::GetExtension($filePath)) {
                ".html" { "text/html; charset=utf-8" }
                ".css" { "text/css; charset=utf-8" }
                ".js" { "application/javascript; charset=utf-8" }
                ".json" { "application/json; charset=utf-8" }
                ".png" { "image/png" }
                ".jpg" { "image/jpeg" }
                ".jpeg" { "image/jpeg" }
                ".gif" { "image/gif" }
                ".svg" { "image/svg+xml" }
                default { "application/octet-stream" }
            }
            
            # Leer y enviar archivo
            $content = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentType = $contentType
            $response.ContentLength64 = $content.Length
            $response.StatusCode = 200
            $response.OutputStream.Write($content, 0, $content.Length)
        }
        else {
            # Archivo no encontrado
            $response.StatusCode = 404
            $html = "<h1>404 - Archivo no encontrado</h1><p>$path</p>"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            
            Write-Host "  ✗ Archivo no encontrado: $filePath" -ForegroundColor Red
        }
        
        $response.Close()
    }
}
finally {
    $listener.Stop()
    Write-Host ""
    Write-Host "Servidor detenido." -ForegroundColor Yellow
}
