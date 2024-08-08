# Requires -RunAsAdministrator

param(
    [Parameter(Mandatory = $true)]
    [string]$ProcessNamePattern
)

# Function to get processes matching the pattern
function Get-MatchingProcesses {
    param([string]$pattern)
    Get-WmiObject Win32_Process | Where-Object { $_.Name -like "*${pattern}*" }
}

# Function to kill a process
function Kill-Process($processId, $processName) {
    try {
        Stop-Process -Id $processId -Force -ErrorAction Stop
        Write-Host "Successfully terminated process '$processName' with ID: $processId"
    }
    catch {
        Write-Host "Failed to terminate process '$processName' with ID: $processId. Error: $_"
    }
}

# Main script
$matchingProcesses = Get-MatchingProcesses -pattern $ProcessNamePattern

if ($matchingProcesses.Count -eq 0) {
    Write-Host "No processes found matching the pattern: $ProcessNamePattern"
}
else {
    Write-Host "Found $($matchingProcesses.Count) matching processes. Terminating..."
    
    foreach ($process in $matchingProcesses) {
        Kill-Process $process.ProcessId $process.Name
    }
    
    Write-Host "Operation completed. Checking for remaining processes..."
    
    $remainingProcesses = Get-MatchingProcesses -pattern $ProcessNamePattern
    if ($remainingProcesses.Count -eq 0) {
        Write-Host "All matching processes have been successfully terminated."
    }
    else {
        Write-Host "Warning: $($remainingProcesses.Count) matching processes still remain."
    }
}

Write-Host "Script execution completed."
