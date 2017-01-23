
function Swift() {
	[CmdletBinding()]
	param (
	[ValidateSet ("install", "uninstall", "update", "list", "available")][string]$op,
	[string]$name = ""
	)

	PROCESS {
		$script_dir = "$HOME\swift_scripts"
		$profile_path = $profile
		$available_scripts_url = "https://raw.githubusercontent.com/amol9/scripts/master/swift/scripts.txt"
		
		#$global:swift_data = Make-Object
		$global:avl = @{}
		
		function Main() {
			Check-Dirs
			
			switch ($op) {
				"install" {
					Get-Available
					Install-Script $name
				}
				
				"available" {
					Get-Available
				}
				
				"uninstall" {
					Uninstall-Script $name
				}
				
				default { "invalid option" }
			}
		}
		
		function Get-Profile () {
			if (! $profile) {
				Write-Host "no profile found, please create a powershell profile"
				Break
			}
			$profile
		}
		
		function Check-Dirs () {
			$exists = Test-Path $script_dir
			if (! $exists) {
				New-Item $script_dir -type Directory
			}
		}
		
		function Install-Script ($name) {
			Check-Name $name
			$url = $global:avl["$name"]
			$filename = $url.Split('/')[-1]
			
			$script_path = "$script_dir\$filename"
			
			Try {
				Invoke-WebRequest -uri $url -Outfile $script_path
			} Catch {
				Write-Host $_.Exception.Message
				Write-Host "error in downloading the script"
				Break
			}
			
			Add-Script-To_Profile $script_path $name
		}
		
		function Uninstall-Script ($name) {
			$profile_path = Get-Profile
			$c = Get-Content $profile_path | Where-Object { $_ -notmatch "swift script $name" }
			Filter-Profile $c | Set-Content $profile_path
		}
		
		function Filter-Profile ($c) {
			$nl = $false
			$out = @()
			ForEach ($l in $c) {
				$cblank = $false
				if ( $l -match "^\s*$" ) {
					$cblank = $true
				} else {
					$nl = $false
				}
				
				if (! ($nl -and $cblank)) {
					$out += $l
				}
				
				$nl = $cblank
			}
			$out
		}
					
		
		function Add-Script-To_Profile($script_path, $script_name) {
			$profile_path = Get-Profile
			Add-Content $profile_path "`n.""$script_path""`t#swift script $script_name"
		}
				
		function Check-Name ($name) {
			if (! $name) {
				Write-Host "script name not provided, please provide one"
				Break
			}
			
			if (! ($name -in $global:avl.Keys) ) {
				Write-Host "invalid script name"
				Break
			}
		}
		
		function Get-Available () {
			#$c = Get-Content $available_scripts_url
			$r = Invoke-WebRequest -uri $available_scripts_url
			$c = $r.Content.Split("`n")
			
			$ol = New-Object System.Collections.ArrayList
			ForEach ($i in $c) {
				$n, $d, $u = $i.Split("`t")
				$o = Make-Object([ordered]@{"Name" = $n; "Description" = $d})
				[void]$ol.Add($o)
				$global:avl.Add($n, $u)
			}
			Write-Object($ol)
		}
		
		function Write-Object($obj) {
			Write-Output $obj | Format-List
		}
		
		function Make-Object($dict) {
			$obj = New-Object PSObject
			
			ForEach ( $h in $dict.GetEnumerator() ) {
				$n = $h.Name
				$obj | Add-Member NoteProperty $n($h.Value)
			}
			
			$obj
		}
		
		function Add-Object-Member($obj, $name, $value) {
			$obj | Add-Member NoteProperty $name($value)
		}
		
		Main		
	}
}
