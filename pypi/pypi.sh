#!/bin/bash

do_parallel=true

list=(vlc-ctrl redcmd redlib wallp imagebot giraf)
pypi_base_url=https://pypi.python.org/pypi


parse_html() {
	html=$(</dev/stdin)
	c=$(echo "$html" | grep -Po "<span>\d+</span> downloads in the last day" | grep -Po "\d+")
	v=$(echo "$html" | tr -d "\n" | grep -Po "<div id=\"breadcrumb\">.*?</div>" | grep -Po "<a.*?>.*?</a>" | sed '3q;d' | sed -rn 's/<a.*>(.*)<\/a>/\1/p')
	printf "%-15s %-10s %6d\n" $1 $v $c
}

parse_json() {
	json=$(</dev/stdin)

	m=$(echo "$json" | python -c "import sys, json; print json.load(sys.stdin)['info']['downloads']['last_month']")
	w=$(echo "$json" | python -c "import sys, json; print json.load(sys.stdin)['info']['downloads']['last_week']")
	d=$(echo "$json" | python -c "import sys, json; print json.load(sys.stdin)['info']['downloads']['last_day']")

	v=$(echo "$json" | python -c "import sys, json; print json.load(sys.stdin)['info']['version']")

	printf "%-15s %-10s %6d %6d %6d\n" $1 $v $m $w $d
}

export -f parse_html
export -f parse_json

printf "%-15s %-10s %6s %6s %6s\n" package version month week day

if [ -z $1 ]
then
	if [ ! -z $do_parallel ]
	then
		printf "%s\n" "${list[@]}" | parallel --gnu --lb "curl -s $pypi_base_url/{}/json | parse_json {}"
	else
		for package in ${list[@]}
		do 
			curl -s $pypi_base_url/$package/json | parse_json $package
		done
	fi
else
	curl -s $pypi_base_url/$1/json | parse_json $1
fi

exit 0

