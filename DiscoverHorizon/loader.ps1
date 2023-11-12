# Define the source and destination paths
$sourcePath = "E:\DiscoverHorizon"
$destinationPath = "C:\Program Files\WindowsPowerShell\Modules\DiscoverHorizon"

# Get all the files in the source directory
$files = Get-ChildItem $sourcePath -Recurse

# Copy each file to the destination directory
foreach ($file in $files) {
    Copy-Item $file.FullName $destinationPath -Force
}
