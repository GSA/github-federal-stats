#$1=file
#$2=word
rv=`sed -ne "s/.*\""$2"\":.*/\0/p" $1 | sed -rn 's/.*'$2'": //;s/,.*//p' | awk '{ total += $1; count++ } END { print total/count }'`

echo $rv
#./parseData/getReposAverage.sh repos.txt watchers