<# 
This is a general purpose script that moves files from a SourcePath to a DestinationPath, 
deletes old files and empty folders from DestinationPath. Does not remove empty folders from source 
as this might break other programs that expect that folder to be there. I realize you can do this 
using robocopy but thought it would be fun to write something myself. I've been using this to create 
a backup of game save states that do not get backed up to the cloud for a number of years.

SourcePath: Folder Path where the files are stored
DestinationPath: Folder Path where the files should be moved to
FileAge: How old a file should be in days before being moved
DeleteAge: How old a file should be in days before being deleted
ScriptRunTime: How long this script should run before exiting (Prevents the script from hanging)
NumberToMove: How many files should be moved before exiting (Used as a safety measure for performance)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $SourcePath,

    [Parameter(Mandatory = $true)]
    [string] $DestinationPath,

    [Parameter(Mandatory = $true)]
    [string] $FileAge,

    [Parameter(Mandatory = $true)]
    [string] $DeleteAge,

    [Parameter(Mandatory = $true)]
    [int] $ScriptRunTime,

    [Parameter(Mandatory = $true)]
    [int] $NumberToMove
)

function move-files ([string] $source, [string] $destination, [int] $age, [int] $maxCount, [double] $runTime) {
    try {
        $count = 0

        Get-ChildItem $source -Recurse -File |
        Where-Object { $_.CreationTime -ge $age } |
        ForEach-Object {
            if ($count -ge $maxCount) {
                Write-Host "Maximum Number of files to move has been reached. Number of files moved: $count"
                return
            }
            if (get-timeCheck -runTime $runTime -function "remove-files") {
                break
            }
            $newPath = $_.FullName -replace [regex]::Escape($source), $destination
            $newDirectory = (Get-Item $_.FullName).DirectoryName -replace [regex]::Escape($source), $destination

            if (!(Test-Path $newDirectory)) {
                New-Item -Path $newDirectory -ItemType Directory -Force | Out-Null
            }
            Move-Item -Path $_.FullName -Destination $newPath -Force
            $moveCount++
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message + $_.Exception.StackTrace
        Write-Host = "Error moving files: $ErrorMessage"
    }
}

function remove-files ([string] $destination, [int] $age, [double] $runTime) {
    try {
        Get-ChildItem $destination -Recurse -File |
        Where-Object { $_.CreationTime -ge $age } |
        ForEach-Object {
            if (get-timeCheck -runTime $runTime -function "remove-files") {
                break
            }
            Remove-Item $_.FullName
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message + $_.Exception.StackTrace
        Write-Host = "Error deleting files: $ErrorMessage"
    }
}

function remove-emptyFolders ([string] $destination, [double] $runTime) {
    try {
        do {
            $emptyFolders = Get-ChildItem $destination -Directory -Recurse | 
            Where-Object { (Get-ChildItem $_.FullName).count -eq 0 } | 
            Select-Object -ExpandProperty FullName

            $emptyFolders |
            ForEach-Object {
                if (get-timeCheck -runTime $runTime -function "remove-emptyFolders") {
                    break
                }
                Remove-Item $_
            }
        } while ($emptyFolders.count -gt 0)
    }
    catch {
        $ErrorMessage = $_.Exception.Message + $_.Exception.StackTrace
        Write-Host = "Error checking time: $ErrorMessage"
    }
}  

function get-timeCheck ([double] $runTime, [string] $function) {
    try {
        if ($timer.elapsed.totalseconds -ge $runTime) {
            Write-Host "RunTimeLimit has been reached. Ending Script at $function."
            return $true
        }
        else {
            return $false
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message + $_.Exception.StackTrace
        Write-Host = "Error checking time: $ErrorMessage"
    }
}

try {
    Write-Host "Starting Script."

    $source = $SourcePath
    $destination = $DestinationPath
    $age = $FileAge
    $deleteAge = $DeleteAge
    $runTime = $ScriptRunTime
    $maxCount = $NumberToMove

    $timer = [Diagnostics.Stopwatch]::StartNew()

    move-files -source $source -destination $destination -age $age -maxCount $maxCount -runTime $runTime

    if (get-timeCheck -runTime $runTime -function "main") {
        break
    }

    remove-files -destination $destination -age $deleteAge -runTime $runTime

    if (get-timeCheck -runTime $runTime -function "remove-emptyFolders") {
        break
    }

    remove-emptyFolders -destination $destination -runTime $runTime

    $timer.Stop()
}
catch {
    $ErrorMessage = $_.Exception.Message + $_.Exception.StackTrace
    Write-Host = "Error checking time: $ErrorMessage"
}