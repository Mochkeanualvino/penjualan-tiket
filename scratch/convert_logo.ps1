Add-Type -AssemblyName System.Drawing
$srcPath = 'C:\Users\DELL\.gemini\antigravity\brain\9cba3778-3897-40e4-b40f-8273cd14cbf9\app_logo_1787412025192.jpg'
$img = [System.Drawing.Image]::FromFile($srcPath)

$dirs = @('mipmap-mdpi', 'mipmap-hdpi', 'mipmap-xhdpi', 'mipmap-xxhdpi', 'mipmap-xxxhdpi')
foreach ($d in $dirs) {
    $dest = "c:\penjualan-tiket\android\app\src\main\res\$d\ic_launcher.png"
    if (Test-Path $dest) { Remove-Item -Path $dest -Force }
    $bmp = new-object System.Drawing.Bitmap($img)
    $bmp.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Converted and saved to $dest"
}
$img.Dispose()
