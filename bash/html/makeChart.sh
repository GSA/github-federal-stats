echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 || -z $5 || -z $6 || -z $7 || -z $8 || -z $9 ) ]]; then
  echo "Usage: makeBarChart.sh [configReader] [configFile] [template] [outputFile] [mappingFile] [title] [range] [direction] [raw data]"
else
  configReader=$1
  configFile=$2
  template=$3
  outputFile=$4
  mappingFile=$5
  title=$6
  range=$7
  direction=$8
  original=$(basename $9)
  
  scriptsDirectory=`$configReader $configFile scriptsDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`

  barTemp=$outputTempDirectory/bar.html.temp
  cp $template $outputFile

  head -n$range $mappingFile > $outputTempDirectory/mapping.temp
  if [ "$direction" == "backward" ]; then
    #put oldest first on x axis...
    grep -n "" $outputTempDirectory/mapping.temp | sort -r -n | gawk -F : '{ print $2 }' > $outputTempDirectory/mapping.temp2
  else
    grep -n "" $outputTempDirectory/mapping.temp | sort -n | gawk -F : '{ print $2 }' > $outputTempDirectory/mapping.temp2
  fi
  cat $outputTempDirectory/mapping.temp2 > $outputTempDirectory/mapping.temp

  echo "[" > $barTemp
  while read -r entry
  do
    pair=$(echo $entry | awk '{print "\x27" $2 "\x27" "," $1}')
    echo "[$pair]," >> $barTemp
  done < $outputTempDirectory/mapping.temp

  sed -i '$s/,$//' $barTemp
  echo "];" >> $barTemp

  echo "inserting chart data into chart page template at $outputFile"
  $scriptsDirectory/parseData/insertDataIntoTemplate.sh $outputFile $barTemp "<!--CHART1-->"

  sed -i "s/<!--CHART1TITLE-->/$title/" $outputFile 
  sed -i "s/<!--RAWDATA-->/$original/" $outputFile 
fi

echo -e "\n---------------exit $0---------------"
