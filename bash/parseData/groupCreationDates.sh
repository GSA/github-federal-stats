echo -e "\n---------------enter $0---------------"
sourceFile=$1
resultFileDaily="$2"Daily.txt
resultFileMonthly="$2"Monthly.txt
resultFileYearly="$2"Yearly.txt

cat $sourceFile | sed '/^$/d' | awk -F ':' '{ print $1 }' | awk -F 'T' '{ print $1 }' | sed 's/\.//g;s/\(.*\)/\L\1/;s/\ /\n/g' | uniq -c > $resultFileDaily

cat $sourceFile | sed '/^$/d' | awk -F ':' '{ print $1 }' | awk -F 'T' '{ print $1 }' | awk -F '-' '{ print $1 "-" $2 }' | sed 's/\.//g;s/\(.*\)/\L\1/;s/\ /\n/g' | uniq -c > $resultFileMonthly

cat $sourceFile | sed '/^$/d' | awk -F ':' '{ print $1 }' | awk -F 'T' '{ print $1 }' | awk -F '-' '{ print $1 }' | sed 's/\.//g;s/\(.*\)/\L\1/;s/\ /\n/g' | uniq -c > $resultFileYearly
echo -e "---------------exit $0---------------"