
function Get-Reddit-Score() {
	[CmdletBinding()]
	param (
	[string]$url = ""
	)

	PROCESS{
		$cache_filepath = "$PSScriptRoot\grs.txt"
		
		function Main() {
			if (! $url) {
				$url = Get-Cached-Url
				if (! $url) {
					Write-Host "no url provided, no cached url found either, please provide a url"
					Break
				} else {
					Write-Host "using cached url: $url"
				}
			}
			
			$r = Invoke-WebRequest -Uri $url
			
			$score = [regex]::match($r.Content, "<div\s+class=.score likes.*?>(.*?)</div>").Groups[1].Value
			$title = [regex]::match($r.Content, "<title>(.*?)</title>").Groups[1].Value
			$comments = [regex]::match($r.Content, "<div class=.commentarea.*?<span\s+class=.title.*?>(.*?)</span>").Groups[1].Value

			$out = New-Object PSObject
			$out | Add-Member NoteProperty Title($title)
			$out | Add-Member NoteProperty Score($score)
			$out | Add-Member NoteProperty Comments($comments)
			
			Write-Output $out | Format-List
			
			Cache-Url $url
		}
		
		function Cache-Url($url) {	
			$url | Set-Content $cache_filepath
		}
		
		function Get-Cached-Url() {
			if (Test-Path $cache_filepath) {
				Get-Content $cache_filepath
			}
		}
		Main
	}
}
