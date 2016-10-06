sqlite3 "$(Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Filter '*.default' | %{$_.FullName})\places.sqlite" "SELECT url FROM moz_places;" | Select-String -Pattern "^http(s)?://(([a-zA-Z0-9](-?[a-zA-Z0-9])*)\.)*([a-zA-Z](-?[a-zA-Z0-9])+)\.[a-zA-Z\.]{3,}" | %{"$($_.matches.groups[5])"} | Sort-Object | Group-Object | Sort-Object Count -Descending | Select -First 10 | Format-Table Name, Count