#!/bin/bash

green='\033[1;32m'
end='\033[1;m'
info='\033[1;33m[!]\033[1;m'
que='\033[1;34m[?]\033[1;m'
bad='\033[1;31m[-]\033[1;m'
good='\033[1;32m[+]\033[1;m'
run='\033[1;97m[~]\033[1;m'

printf """$green     ___  _               
    / _ \(_)__ ____ ___ __
   / // / / _ \`/ _ \`/ // /
  /____/_/\_, /\_, /\_, / 
         /___//___//___/  

$end"""

if [ -z "$1" ]; then
    printf "Usage: ./apk.sh <path to apk file>\n"
    return 1
fi

apk=$1
dir=$( pwd )
name=$(echo "$apk" | sed -E "s|[^a-zA-Z0-9]+|-|")

decom="$dir/$name"
links="$dir/$name.txt"

touch $links

if type "apktool" > /dev/null; then
  :
else
    printf "$bad Diggy requires 'apktool' to be installed."
    return 1
fi

extract() {
    k=$(apktool d $apk -o $decom -fq)
}

regxy() {
    matches=$(grep -EroI "[\"'\`](https?://|/)[\w\.-/]+[\"'\`]")
    for final in $matches; do
        
        final=${final//$"\""/}
        final=${final//$"'"/}
        if [ $(echo "$final" | grep "http://schemas.android.com") ]
        then
            :
        else
            echo "$final" >> "$links"
        fi
    done
    awk '!x[$1]++' $links
}


printf $"$run Decompiling the apk\n"
extract
printf $"$run Extracting endpoints\n"
regxy
printf $"$info Endpoints saved in: $links\n"