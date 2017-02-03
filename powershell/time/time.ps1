# measures execution time of last command or the given command

function Time() {
    param (
        [string]$command    = $null
    )

    PROCESS {
        function Main() {
            $sb = $null

            if ($command) {
                $sb = [scriptblock]::Create($command + " | Out-Default")
            }
            Get-Time $sb
        }

        function Get-Time($sb) {
            $t = $null

            if($sb) {
                $t = Measure-Command $sb
            } else {
                $h = Get-History -Count 1
                $t = $h.EndExecutionTime - $h.StartExecutionTime
            }

            $s = $t.TotalSeconds
            $ms = $t.TotalMilliSeconds

            Write-Host "$s s ($ms ms)"
        }
        Main
    }
}
