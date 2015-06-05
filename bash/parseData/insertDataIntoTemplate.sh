echo -e "\n---------------enter $0---------------"

originalFile=$1
insertedTextFile=$2
token=$3

awk '{print $0 > "tempfile" NR}' RS=$token $originalFile
cat tempfile1 > $originalFile
cat $insertedTextFile >> $originalFile
cat tempfile2 >> $originalFile
rm tempfile1
rm tempfile2

echo -e "---------------exit $0---------------"


