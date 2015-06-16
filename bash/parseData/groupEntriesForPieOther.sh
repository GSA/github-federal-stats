echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 ) ]]; then
  echo "Usage: groupEntriesForPieOther.sh [inputFile] [outputFile] [range] [cutoff:optional]"
else
  inputFile=$1
  outputFile=$2
  range=$3

  ttlLines=`grep -c ^ $inputFile`
  if [ "$ttlLines" -le "$range" ]; then
    cat $inputFile > $outputFile	
  else
    range=$((range - 1))
    head -n$range $inputFile > $outputFile
    range=$((ttlLines - range))   

    if [[ ( -z $4 )]]; then
      totalOther=`tail -n$range $inputFile | awk '{ total += $1 } END { print total }'`
    else
      totalOther=`head -n$4 $inputFile | tail -n$range | awk '{ total += $1 } END { print total }'`
    fi
    echo -e "     $totalOther     Other" >> $outputFile
  fi
fi

echo -e "\n---------------exit $0---------------"