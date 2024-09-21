# Define the process name and the path to the executable
$processName = "eqgame"
$exePath = "C:\Games\EverQuest\EverQuest-RoF-WT\"
$exeFullPath = $exePath + $processName + ".exe"

# List of character names
$characterNames = @("CharacterOne", "CharacterTwo")
# Server Short Name to reconnect to
$serverName = "wastingtime"

# Loop that continuously checks if the process is running
while ($true) {
    # Check for the "EverQuest Crash" window and terminate the specific process if found
    $crashWindow = Get-Process | Where-Object { $_.MainWindowTitle -match 'EverQuest Crash' }
    
    if ($crashWindow) {
        foreach ($cw in $crashWindow) {
            $timestamp = (Get-Date).ToString("MM-dd-yyyy HH:mm:ss")
            $message = "EverQuest Crash detected. Terminating eqgame.exe (PID: $($cw.Id))..."
            Write-Host "$timestamp - $message"
            Stop-Process -Id $cw.Id -Force
        }
        Start-Sleep -Seconds 1
    }

    # Check if the process is running
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

    # Loop through each character name
    foreach ($charName in $characterNames) {
        # Check if an eqgame process with the character name in the arguments exists
        $runningProcess = Get-WmiObject Win32_Process | Where-Object { 
            $_.Name -eq "$processName.exe" -and $_.CommandLine -like "*$($serverName):$($charName)*"
        }

        if ($runningProcess) {
            # If the process exists, print a message
            $timestamp = (Get-Date).ToString("MM-dd-yyyy HH:mm:ss")
            $message = "Process found for '$charName'."
            # Write-Host "$timestamp - $message"
        }

        if (-not $runningProcess) {
            # If the process doesn't exist, start the process for the character
            $timestamp = (Get-Date).ToString("MM-dd-yyyy HH:mm:ss")
            $message = "No running process found for '$charName'. Starting it now..."
            Write-Host "$timestamp - $message"
            Start-Process -FilePath $exeFullPath -ArgumentList @("patchme", "/login:$($serverName):$($charName)") -WorkingDirectory $exePath
        }
    }

    # Wait 10 seconds before checking again (adjust as needed)
    Start-Sleep -Seconds 10
}