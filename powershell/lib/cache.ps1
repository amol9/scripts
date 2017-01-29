# library for caching

$cache_filepath = "$PSScriptRoot\cache.xml"
$cache_namespace = $null

function Cache-Set($key, $value, $filepath = $cache_filepath) {
	$dict = Cache-Load $filepath
	$cmdlet_dict = Cache-Get-NS-Dict $dict
	$cmdlet_dict[$key] = $value
	
	Cache-Save $dict $filepath
}

function Cache-Save($dict, $filepath = $cache_filepath) {
	Export-Clixml -InputObject $dict -Path $filepath
}

function Cache-Load($filepath = $cache_filepath) {
	$dict = @{}
	
	if (Test-Path $filepath) {
		$dict = Import-Clixml -Path $cache_filepath
	}
	$dict
}

function Cache-Get($key, $value = $null, $filepath = $cache_filepath) {
	$dict = Cache-Load $filepath
	$cmdlet_dict = Cache-Get-NS-Dict $dict
	if ( $key -in $cmdlet_dict.Keys ) {
		$cmdlet_dict[$key]
	} else {
		$value
	}
}

function Cache-Get-NS-Dict($dict) {
	if (! $cache_namespace) {
		Throw "cache namespace cannot be null"
	}
	
	if (! ($cache_namespace -in $dict.Keys)) {
		$dict[$cache_namespace] = @{}
	}
	$dict[$cache_namespace]
}

function Cache-Clear($filepath = $cache_filepath) {
	$dict = Cache-Load $filepath
	$cmdlet_dict = Cache-Get-NS-Dict $dict
	$cmdlet_dict.Clear()
	
	Cache-Save $dict $filepath
}
