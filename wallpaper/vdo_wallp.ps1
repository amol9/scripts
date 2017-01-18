
function Vdo-Wallp() {
	param (
		[string]$url 		= "",
		[string]$time 		= "00:00:00",
		[switch]$debug 		= $false,
		[string]$fmt		= "jpg",
		[switch]$play		= $false
		[string]$style		= [centered, zoom]
	)

	PROCESS {

		$prog_dir = "$HOME\vdo_wallp"
		$cache_path = "$prog_dir\cache"
		$pictures_dir = "$HOME\Pictures"
		$wallpaper_basename = "vdo_wallp"

		function Check-Dirs(){
			$exists = Test-Path $prog_dir
			if (! $exists){
				Write-Output "creating program directory..."
				New-Item $prog_dir -type Directory
				Write-Output "program directory created at: $prog_dir"
			}

			$exists = Test-Path $cache_path
			if (! $exists) {
				Write-Output "creating cache directory..."
				New-Item $cache_path -type Directory
				Write-Output "cache directory created at: $cache_path"
			}
		}

		function Set-WallPaper($value)
		{
			Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $value
			rundll32.exe user32.dll, UpdatePerUserSystemParameters

			Try {
				wallp style auto
			} Catch {
				Write-Output "wallp (wallpaper utility written in python, https://pypi.python.org/pypi/wallp) is not installed. Unable to set wallpaper style automatically."
			}
		}

		function Parse-Gfycat-Url($url)
		{
			$r = [regex]::match($url, "^http.://gfycat.com/(\w+)")
			if ($r.Success) {
				$gfycat_id = $r.Groups[1].Value
				Write-Output "https://giant.gfycat.com/$gfycat_id.webm"
			} else {
				Write-Output "invalid gfycat url"
				exit
			}

		}

		function Process-Url($url) {
			if ($url -match "gfycat") {
				Parse-Gfycat-Url $url
			} else {
				Write-Output $url
			}
		}

		function Present-In-Cache($filename){
			$filepath = "$cache_path\$filename"
			Test-Path $filepath
		}

		function Fetch-Url($url) {
			$url = Process-Url $url
			$filename = [regex]::match($url, "^.*/(.*)").Groups[1].Value
			$filepath = "$cache_path\$filename"

			$is_cached = Present-In-Cache $filename
			if (! $is_cached) {
				Write-Host "fetching url: $url to $filepath"
				Invoke-Webrequest -Uri $url -OutFile $filepath
			} else {
				Write-Host "using cached file: $filepath"
			}
			Write-Output $filepath
		}

		function Get-Url($url){
			if ($url.StartsWith("http")){
				Fetch-Url $url
			} else {
				Write-Output $url
			}
		}

		function Extract-Frame($filepath, $time) {
			$wallpaper_path = "$pictures_dir\$wallpaper_basename.$fmt"
			Try {
				Write-Host "time: $time"
				Invoke-Expression "ffmpeg -ss $time -i `"$filepath`" -frames:v 1 $wallpaper_path -y" 1>$null 2>$null
				Write-Host "frame extracted to: $wallpaper_path"
			} Catch {
				Write-Host $_.Exception.Message
				exit
			}
			Write-Output $wallpaper_path
		}

		function Try-Wallpapers($filepath) {
			for($i=0; $i -lt 60; $i++) {
				$time = "00:00:0$i"
				$wp = Extract-Frame $filepath $time
				Set-WallPaper $wp
				$done = Read-Host -Prompt 'Continue? (Y/n): '

				if (! ($done -eq 'Y' -or $done -eq 'y' -or $done -eq '')) {
					break
				}
			}
		}

		function Main() {
			Check-Dirs
			$filepath = Get-Url $url
			if (! $play) {
				$wp = Extract-Frame $filepath, $time
				Set-WallPaper $wp
			} else {
				Try-Wallpapers $filepath
			}	
		}

		Main
	}
}
