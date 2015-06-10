echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 || -z $5 || -z $6 ) ]]; then
  echo "Usage: makeBarChart.sh [configReader] [configFile] [outputFile] [mappingFile] [title] [range]"
else
  configReader=$1
  configFile=$2
  outputFile=$3
  mappingFile=$4
  title=$5
  range=$6
  
  scriptsDirectory=`$configReader $configFile scriptsDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`

  barTemp=$outputTempDirectory/bar.html.temp
  cp $scriptsDirectory/html/barChart.template $outputFile

  #put oldest first on x axis...
  head -n$range $mappingFile > $outputTempDirectory/mapping.temp
  grep -n "" $outputTempDirectory/mapping.temp | sort -r -n | gawk -F : '{ print $2 }' > $outputTempDirectory/mapping.temp

  echo "[" > $barTemp
  while read -r entry
  do
    pair=$(echo $entry | awk '{print "\x27" $2 "\x27" "," $1}')
    echo "[$pair]," >> $barTemp
  done < $outputTempDirectory/mapping.temp

  sed -i '$s/,$//' $barTemp
  echo "];" >> $barTemp

  echo "inserting bar chart data into bar chart page template at $outputFile"
  $scriptsDirectory/parseData/insertDataIntoTemplate.sh $outputFile $barTemp "<!--BARCHART1-->"

  sed -i "s/<!--BARCHART1TITLE-->/$title/" $outputFile 
fi

