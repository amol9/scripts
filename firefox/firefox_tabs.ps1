. $PSScriptRoot\bluelib.ps1

function Firefox-Tabs() {
	[CmdletBinding()]
	param (
	[string]$url	= ".*",
	[string]$title	= ".*",
	[switch]$blank
	)

	PROCESS{
		function Main() {
			Write-Host `n
			$rjs = Get-Recovery-JS
			Get-Tabs $rjs
		}
		
		function Get-Recovery-JS () {
			$profile_path = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Filter '*.default' | %{$_.FullName}
			
			Get-Content $profile_path\sessionstore-backups\recovery.js
		}
		
		function Get-Tabs($rjs) {
			$rjson = $rjs | ConvertFrom-Json
			
			$wc = 0
			ForEach ($w in $rjson.windows) {
				$wc++
				Write-Host "Window: $wc"
				
				$tl = New-Object System.Collections.ArrayList
				
				ForEach ($t in $w.tabs) {
					$e = $t.entries[-1]
					
					if (Filter-Tab $e.title $e.url) {
						$o = Make-Object([ordered]@{"Title" = $e.title; "Url" = $e.url})
						[void]$tl.Add($o)
					}
				}
				Write-Object($tl)
			}
		}
		
		function Filter-Tab ($t, $u) {
			$f = [regex]::Match($t, "(?i)$title").Success -and [regex]::Match($u, "(?i)$url").Success
			$b = ! (!$blank -and [regex]::Match($u, "about:.*").Success)
			$f -and $b
		}
		Main
	}
}
