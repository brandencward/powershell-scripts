# random-scripts

This is a random collection of powershell scripts I felt like sharing. All of the projects I post are just things I
played around with to learn and are by no means perfect :stuck_out_tongue_closed_eyes:. I made these just for fun and to improve my skills. Hopefully
you find these examples useful for your projects.

## simpleArchive.ps1

This is a general purpose script that moves files from a SourcePath to a DestinationPath, 
deletes old files and empty folders from DestinationPath. Does not remove empty folders from source 
as this might break other programs that expect that folder to be there. I realize you can do this 
using robocopy but thought it would be fun to write something myself. I've been using this to create 
a backup of game save states that do not get backed up to the cloud for a number of years.


- **SourcePath**: *Folder Path where the files are stored*
- **DestinationPath**: *Folder Path where the files should be moved to*
- **FileAge**: *How old a file should be in days before being moved*
- **DeleteAge**: *How old a file should be in days before being deleted*
- **ScriptRunTime**: *How long this script should run before exiting*
- **NumberToMove**: *How many files should be moved before exiting*
