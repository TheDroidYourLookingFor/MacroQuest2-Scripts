# Set the folder path where your files are located
$folderPath = "C:\Games\EverQuest-RoF-EZ-Alts"

# Get all files in the folder that end with _chr.txt
$fileList = Get-ChildItem -Path $folderPath -Filter "*_chr.txt"

# Define the replacement text
$replacementText = @"
1
dke,dke
"@

# Loop through each file and replace its content
foreach ($file in $fileList) {
    $replacementText | Set-Content -Path $file.FullName
}
