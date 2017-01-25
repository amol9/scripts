#common lib

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