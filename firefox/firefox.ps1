param (
	[string]$query 		= "",
	[int32]$limit 		= 100000,
	[switch]$debug 		= $false,
	[datetime]$start 	= 0,
	[datetime]$end 		= 0,
	[int32]$top			= 0,
	[switch]$summary	= $false,
	[string]$timesort	= [asc, dsc]
)


[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null

$stopwatch = [Diagnostics.Stopwatch]::StartNew()
$time_window_period = 10*60		# 15 minutes

$global:result = New-Object System.Collections.ArrayList
$global:summary = New-Object PSObject


function Debug-Print($str) {
	if ($debug) {
		Write-Host -Foreground Red [DEBUG]: $str
	}
}

function Process-Result-Item($query, $time, $time_window) {
	$d_query = [System.Web.HttpUtility]::UrlDecode($query)
	$obj = New-Object PSObject
	$obj | Add-Member NoteProperty DateTime($time)
	$obj | Add-Member NoteProperty TimeWindow($time_window+$query)
	$obj | Add-Member NoteProperty Query($d_query)
	
	[void]$global:result.Add($obj) 
	Debug-Print $obj
}

function Query-Firefox-DB($query, $limit, $time_window) {
	$e_query = [System.Web.HttpUtility]::UrlEncode($query)
	
	$sql_base = "SELECT url, datetime(last_visit_date/1000000,'unixepoch','localtime'), (last_visit_date/1000000)/$time_window_period FROM moz_places WHERE url LIKE '%google.co%search?q=%$e_query%'"
	$sql_period = "last_visit_date BETWEEN $start_timestamp AND $end_timestamp"
	$sql_timesort = "ORDER BY last_visit_date" #ASC/DESC
	$sql_limit = "LIMIT $limit"
	
	Debug-Print $sql
	
	$profile_path = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Filter '*.default' | %{$_.FullName}
	Debug-Print $profile_path
	
	sqlite3.exe $profile_path\places.sqlite $sql | Select-String -Pattern "q=(.*?)&.*\|(.*)\|(.*)" | % {Process-Result-Item "$($_.matches.groups[1])" "$($_.matches.groups[2])" "$($_.matches.groups[3])"}
	Filter-Duplicates
}

function Filter-Duplicates() {
	$global:result = $result.ForEach{Write-Output $_} | Sort-Object TimeWindow -unique #| Format-Table Query, DateTime
}

function Top-N($count) {
	$result.ForEach{Write-Output $_} | Sort-Object -Property Query | Group-Object -Property Query | Sort-Object Count -Descending | Select -First $count | %{$_ | Add-Member NoteProperty Query($_.Name); $_} | Format-Table Query, Count
}

function Print-Summary {
	$global:summary | Add-Member NoteProperty TotalQueries($result.Length)
	$stopwatch.Stop()
	$ts = $stopwatch.Elapsed.toString("hh\:mm\:ss\,fff")
	$global:summary | Add-Member NoteProperty Time($ts)
	Write-Output Summary:
	Write-Output $global:summary
}

function Main() {
	Query-Firefox-DB $query $limit

	if ($top -gt 0) {	
		Top-N $top
	} else {
		$result.ForEach{Write-Output $_} | Format-Table Query, DateTime
	}

	if ($summary) {
		Print-Summary
	}
}

Main()


# stats: total, per day, top
# start, end (month, year, week)
# sort
# get-random
# domains
# top urls
