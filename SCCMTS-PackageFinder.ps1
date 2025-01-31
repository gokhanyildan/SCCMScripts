# Import SCCM module
Import-Module "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"

# Connect to SCCM site
$siteCode = "GYC"  # Replace with your SCCM site code
Set-Location -Path "$siteCode`:"

# Path to the CSV file containing Package IDs
$csvPath = "C:\Temp\RetiredPackages.csv"  # Replace with the actual path to your CSV file

# Import Package IDs from CSV
$packageIDs = Import-Csv -Path $csvPath | Select-Object -ExpandProperty PackageID

# Get all task sequences
$taskSequences = Get-CMTaskSequence

# Initialize a list to store results
$results = @()

# Loop through each task sequence
foreach ($ts in $taskSequences) {
    # Get the package references in the task sequence
    $tsPackages = $ts.References.Package

    # Check if any of the package IDs from the CSV are in this task sequence
    foreach ($packageID in $packageIDs) {
        if ($packageID -in $tsPackages) {
            # Add the task sequence name and package ID to the results
            $results += [PSCustomObject]@{
                TaskSequenceName = $ts.Name
                PackageID        = $packageID
            }
        }
    }
}

# Output the results
if ($results.Count -gt 0) {
    Write-Host "The following task sequences contain the specified packages:" -ForegroundColor Green
    $results | Format-Table -AutoSize
} else {
    Write-Host "No task sequences found containing the specified packages." -ForegroundColor Yellow
}

# Export results to a CSV file (optional)
$results | Export-Csv -Path "C:\Temp\TaskSequencesWithPackages.csv" -NoTypeInformation
Write-Host "Results exported." -ForegroundColor Cyan