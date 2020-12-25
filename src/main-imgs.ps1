$configName = 'config.json'
# $configName = '.\config-test.json'
$cfg = Get-Content $configName -errorAction stop | ConvertFrom-Json
$fileName = ".\no-datetaken.csv"
$timeNow = Get-Date -Format "o"

$Shell = New-Object -ComObject shell.application

$list = New-Object Collections.Generic.List[String]
$list.Add($timeNow)

foreach ($folder in $cfg.folders) {	

	Get-ChildItem $folder.path -Include $cfg.imgExts -Recurse | ForEach-Object {
		$dir = $Shell.Namespace($_.DirectoryName)
		$isDateTaken = ($dir.GetDetailsOf($dir.ParseName($_.Name), 12) -replace '[^: \w\/]')
		if ($isDateTaken) {						
		
			$DateTaken = [DateTime]$isDateTaken		
	
			Set-ItemProperty -Path $_.FullName -Name CreationTime -Value $DateTaken	
			Set-ItemProperty -Path $_.FullName -Name LastWriteTime -Value $DateTaken	
		}
		else {
		
			# Write-Host "$($_.FullName)"
			$list.Add($_.FullName)
			$dtModified = [DateTime](Get-ItemProperty $_.FullName -Name LastWriteTime).LastWriteTime
			$dtCreated = [DateTime](Get-ItemProperty $_.FullName -Name CreationTime).CreationTime
		
			if ($dtModified -lt $dtCreated) {		
				Set-ItemProperty -Path $_.FullName -Name CreationTime -Value $dtModified
			} 
		
			if ($dtCreated -lt $dtModified) {		
				Set-ItemProperty -Path $_.FullName -Name LastWriteTime -Value $dtCreated
			} 
	
		}
	
	}
}

$list | Out-File $fileName
