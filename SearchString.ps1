# PowerShell script to search for a string in files (case insensitive)
# and highlight the matching text in red.

param (
    [string]$SearchPath = ".", # Default to the current directory
    [string]$SearchString # The string to search for
)

# Check if the search string is provided
if (-not $SearchString) {
    Write-Host "Please provide a search string using the -SearchString parameter." -ForegroundColor Yellow
    exit
}

# Function to highlight matches in red
function Highlight-Match {
    param (
        [string]$Text,
        [string]$Match
    )
    # Replace matches with red-highlighted text using ANSI escape codes
    $Highlighted = $Text -replace ($Match), "`e[31m$($Match)`e[0m"
    return $Highlighted
}

# Get all files in the directory and subdirectories
Get-ChildItem -Path $SearchPath -Recurse -File | ForEach-Object {
    $FilePath = $_.FullName

    # Read the file content
    try {
        Get-Content -Path $FilePath -ErrorAction Stop | ForEach-Object {
            $Line = $_
            $LineNumber = $global:LineNumber += 1

            # Check for the search string (case-insensitive)
            if ($Line -match "(?i)$SearchString") {
                $HighlightedLine = Highlight-Match -Text $Line -Match $SearchString
                # Print the file path, line number, and highlighted line
                Write-Host "Found in $FilePath (Line $LineNumber):" -ForegroundColor Green
                Write-Host $HighlightedLine
            }
        }
    } catch {
        Write-Host "Could not read file: $FilePath" -ForegroundColor Yellow
    }

    $global:LineNumber = 0
}
