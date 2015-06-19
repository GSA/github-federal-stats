rv=`sed -ne "s/.*\"$2\":.*/\0/p" $1 | sed "s/\""$2"\"://" | sed 's/.$//' | sed 's/"\(.*\)"$/\1/'`
if [[ "   null" == "$rv" ]]; then
  rv="";
fi
echo $rv
