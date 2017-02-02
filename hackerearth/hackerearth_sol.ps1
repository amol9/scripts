. $PSScriptRoot\bluelib.ps1
. $PSScriptRoot\cache.ps1

function Hackerearth-Sol() {
	[CmdletBinding()]
	param (
		[string]$solution	= "",
		[string]$url		= "",
		[string]$path		= "",
		[string]$root		= $null,
		[switch]$no_commit,
		[switch]$no_push,
		[string]$git_msg	= $null,
		[switch]$stay,
		[switch]$dbg
	)
	
	PROCESS {
		$root_path = $null
		$info_filename = "info.txt"
		$solution_file_base = "solution"
		$topics_to_path_map_file = "$PSScriptRoot\he_topics_to_path_map.txt"
		$practice_problems_dir = "practice"
		$git_commit = !$no_commit
		$git_push = !$no_push
		$stay_in_sol_dir = $stay
		
		# bluelib.ps1
		$debug = $dbg
		
		# cache.ps1
		$cache_namespace = "hackerearth-sol"
		
		function Main() {
			$root_path = Get-Root $root
			if ($solution) {
				Process-Temp-Solution $solution
			}
		}
		
		function Get-Root($root) {
			if (! $root) {
				$cr = Cache-Get "root"
				if ((! $cr) -or ($cr.Length -lt 4)) {
					Write-Host "please provide a path to root directory for solutions"
					Break
				}
				Write-Host "using cached root directory for solutions: $cr"
				$cr
			} else {
				Cache-Set "root" $root
				$root
			}
		}
		
		function Process-Temp-Solution($solution) {
			$sol = Get-Content $solution
			
			$url = Extract-Field "he:url" $sol
			Debug-Print "url: $url"
			
			$tags = Extract-Field "he:tags" $sol
			Debug-Print "tags: $tags"
			
			$path = Extract-Field "he:path" $sol
			Debug-Print "path: $path"
			
			if(!$tags -or !$path) {
				$tags, $path = Parse-Problem-Page $url
				Debug-Print "tags: $tags, path: $path"
			}
			
			$code = $sol | Where-Object { $_ -notmatch "^.*he:(url|tags|path).*$" }
			#Debug-Print "code:`n$code"
			
			$ext = $solution.Split('.')[-1]
			
			$fullpath = "$root_path\$practice_problems_dir\$path"
			Make-Dirs $fullpath
			
			Write-Host "Url: $url"
			Write-Host "Tags: $tags"
			Write-Host "Fullpath: $fullpath"
			
			Write-Solution-File $code $ext $fullpath
			Write-Info-Txt $url $tags $fullpath
			
			if ($git_commit) {
				Git-Commit $fullpath $git_msg $git_push
			}
		}
		
		function Extract-Field($field_name, $sol) {
			$field_name_w_col = $field_name + ":"
			$line = $sol | Where-Object { $_ -Match $field_name_w_col }
			if(! $line) {
				return
			}
			
			$idx = $line.IndexOf($field_name_w_col) + $field_name_w_col.Length + 1
			$line.Substring($idx).Trim()
		}
		
		function Make-Dirs($path) {
			if (! (Test-Path $path)) {
				$o = New-Item $path -Type Directory
			}
		}
		
		function Write-Solution-File($content, $ext, $path) {
			$fullpath = "$path\$solution_file_base.$ext"
			$content | Set-Content $fullpath
			Trim-File $fullpath
		}
		
		function Write-Info-Txt($url, $tags, $path) {
			$content = "url: $url`r`ntags: $tags`n"
			$content | Set-Content "$path\$info_filename"
		}
		
		function Get-Tags($phtml) {
			$div = $phtml.getElementsByTagName('div') | Where { $_.getAttributeNode('class').Value -eq 'problem-tags content' }
			$div.innerText.Split(':')[-1]
		}
		
		function Get-Topics($phtml) {
			$spans = $phtml.getElementsByTagName('span') | Where { $_.getAttributeNode('class').Value -match 'topic link-color' }
			$topic_list = ( $spans | %{ $_.innerText } )
			$ofs = " > "
			$topics = "$topic_list"
			Debug-Print "topics: $topics"
			$topics
		}
		
		function Make-Path($topics) {
			$map = Get-Content $topics_to_path_map_file
			
			ForEach ($m in $map) {
				$t, $p = $m.Split(':')
				if ($t -Match $topics) {
					return $p.Trim()
				}
			}
			Write-Host "path for topics not found: $topics"
			Break
		}
		
		function Get-Problem-Page-Html($url) {
			if (! $global:hesort) {
				$r = Invoke-WebRequest -Uri $url #-UseBasicParsing
				if ($dbg) {
					$global:hesort = $r.ParsedHtml
				}
				$r.ParsedHtml
			} else {
				$global:hesort
			}
		}
		
		function Parse-Problem-Page($url) {
			$phtml = Get-Problem-Page-Html $url
			$tags = Get-Tags $phtml
			$topics = Get-Topics $phtml
			$path = Make-Path $topics
			$problem_name = $phtml.title.Split('|')[0].Trim().ToLower().Replace(' ', '_')
			$tags, "$path\$problem_name"
		}
		
		function Git-Commit($fullpath, $message, $git_push) {
			if (! (Confirm-Proceed "Now, I'll change to the solution directory to commit.")) {
				Write-Host "not adding to git"
				return
			}
			
			$cwd = pwd
			cd $fullpath
			git add .
			
			$m = $null
			if ($git_msg) {
				$m = "-m $git_msg"
			}
			
			git commit "$m"
			$commit_r = $?
			
			if($commit_r -and $git_push) {
				if (! (Confirm-Proceed "Pushing the commit.")) {
					Write-Host "commit not pushed"
				} else {
					git push
				}
			}
			
			if (! $stay_in_sol_dir){
				cd $cwd.Path
			}
		}
		
		function Confirm-Proceed($msg, $break) {
			$full_msg = $msg + "`n" + "Are you sure you want to proceed: (y/n)"
			$ch = Read-Host $full_msg
			
			if ($ch -eq 'y') {
				return $true
			} else {
				if ($break) {
					Break
				}
				return $false
			}
		}
		
		Main
	}
}
