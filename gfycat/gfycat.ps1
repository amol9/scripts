. $PSScriptRoot\bluelib.ps1
. $PSScriptRoot\cache.ps1

function Gfycat-Download() {
	[CmdletBinding()]
	param (
		[string]$url	= "",
		[string]$id		= "",
		[ValidateSet("mp4", "webm", "gif")]
		[string]$format	= "webm",
		[string]$dir	= $null,
		[switch]$dbg
	)
	
	PROCESS {
		$cache_namespace = "gfycat-download"
		$debug = $dbg
		
		function Main() {
			$d = Get-Dir $dir
			$j = Get-Gfycat-Json $url $id
			Download-File $j $format $d
		}
		
		function Get-Dir($dir) {
			if(! $dir) {
				$dir = Cache-Get "dir"
				if(! $dir) {
					Throw "please provide path to download directory"
				}
				Write-Host "using cached directory path for download: $dir"
			}
			
			if(! (Test-Path $dir)) {
				New-Item $dir -Type Directory
			}
			Cache-Set "dir" $dir
			$dir	
		}
		
		function Get-Gfycat-Json($url, $id) {
			if($url.Length -gt 0) {
				$id = $url.Split('/')[-1]
				Debug-Print $id
			}
			
			$json_url = "https://gfycat.com/cajax/get/$id"
			Debug-Print "json url: $json_url"
			
			$r = Invoke-WebRequest -Uri $json_url
			$r.Content | ConvertFrom-Json
		}
			
		function Download-File($j, $format, $dir) {
			$url = $null
			$g = $j.gfyItem
			
			Debug-Print "format: $format"
			switch ($format) {
				"webm"	{ $url = $g.webmUrl }
				"mp4"	{ $url = $g.mp4Url	}
				"gif"	{ $url = $g.gifUrl	}
				default	{ Throw "invalid format: $format" }
			}
			
			$filename = $url.Split('/')[-1]
			$filepath = "$dir\$filename"
			Invoke-WebRequest -Uri $url -Outfile $filepath
			
			Write-Host "downloaded to: $filepath"
		}
		Main
	}
}
