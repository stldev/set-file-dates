# $configName = 'config.json'
$configName = '.\config-test.json'
$cfg = Get-Content $configName -errorAction stop | ConvertFrom-Json
$fileName = ".\no-mediacreated.csv"
$timeNow = Get-Date -Format "o"

$Shell = New-Object -ComObject shell.application

$list = New-Object Collections.Generic.List[String]
$list.Add($timeNow)

foreach ($folder in $cfg.folders) {	

	Get-ChildItem $folder.path -Include $cfg.vidExts -Recurse | ForEach-Object {
		$dir = $Shell.Namespace($_.DirectoryName)
		$isMediaCreated = ($dir.GetDetailsOf($dir.ParseName($_.Name), 208) -replace '[^: \w\/]')
		if ($isMediaCreated) {						
		
			$mediaCreated = [DateTime]$isMediaCreated		
	
			Set-ItemProperty -Path $_.FullName -Name CreationTime -Value $mediaCreated	
			Set-ItemProperty -Path $_.FullName -Name LastWriteTime -Value $mediaCreated	
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
