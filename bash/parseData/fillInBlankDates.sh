echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 ) ]]; then
  echo "Usage: groupEntriesForPieOther.sh [inputFile] [outputFile] [D|M|Y] [range] "
else
  inputFile=$1
  outputFile=$2
  dmy=$3
  range=$4

  echo -e > $outputFile

  if [[ ! -z $range ]]; then
    #to account for the until loop
    range=$(( range + 1 ))
    head -n$range $inputFile > $inputFile.tmp
    inputFile=$inputFile.tmp
  fi

  if [ "$dmy" = "D" ]; then    
     i=0
     smallest=`awk 'BEGIN {min = 2090-10-10} {if ($2<min) min=$2} END {print min}' $inputFile`
     theDate=`date -d"today-$i days" +%Y-%m-%d`

     while [ "$i" != "$range" ]; do
       theLine=`grep "$theDate" "$inputFile"`
       if [ "$theLine" ]; then
         echo $theLine >> $outputFile 
       else
         echo "0 $theDate" >> $outputFile
       fi
       i=$(( i + 1 ))
       theDate=`date -d"today-$i days" +%Y-%m-%d`
#echo "day i:$i  range: $range  smallest: $smallest  date: $theDate"
     done
  elif [ "$dmy" = "M" ]; then    
     i=0
     smallest=`awk 'BEGIN {min = 2090-10} {if ($2<min) min=$2} END {print min}' $inputFile`
     theDate=`date -d"today-$i months" +%Y-%m`
     
     while [ "$i" != "$range" ]; do
       theLine=`grep "$theDate" "$inputFile"`
       if [ "$theLine" ]; then
         echo $theLine >> $outputFile 
       else
         echo "0 $theDate" >> $outputFile
       fi
       i=$(( i + 1 ))
       theDate=`date -d"today-$i months" +%Y-%m`
#echo "month i:$i  range: $range  date: $theDate"
     done
  else
     i=0
     smallest=`awk 'BEGIN {min = 2090} {if ($2<min) min=$2} END {print min}' $inputFile`
     theDate=`date -d"today-$i years" +%Y`

     while [ "$i" != "$range" ]; do
       theLine=`grep "$theDate" "$inputFile"`
       if [ "$theLine" ]; then
         echo $theLine >> $outputFile 
       else
         echo "0 $theDate" >> $outputFile
       fi
       i=$(( i + 1 ))
       theDate=`date -d"today-$i years" +%Y`
     done
  fi

  if [[ ! -z $range ]]; then
    head -n$range $outputFile > $outputFile.tmp
    cat $outputFile.tmp > $outputFile
    rm $outputFile.tmp
  fi

  sed -i '/^$/d' $outputFile
cat $outputFile
fi

echo -e "\n---------------exit $0---------------"