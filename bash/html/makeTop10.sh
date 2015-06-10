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

  topTenTemp=$outputTempDirectory/topTen.html.temp
  cp $scriptsDirectory/html/topTen.template $outputFile

  head -n$range $mappingFile > $outputTempDirectory/topTenmapping.temp

  echo "$title<br><br><table>" > $topTenTemp
  while read -r entry
  do
    pair=$(echo $entry | awk -F'Z:' '{print "<a href=\"https://github.com/" $2 "\">" $2 "</a></td><td>" $1}')
    echo "<tr><td>$pair</td></tr>" >> $topTenTemp
  done < $outputTempDirectory/topTenmapping.temp

  echo "</table>" >> $topTenTemp

  echo "inserting top Ten data into template at $outputFile"
  $scriptsDirectory/parseData/insertDataIntoTemplate.sh $outputFile $topTenTemp "<!--TOPTEN1-->"

  sed -i "s/<!--PAGE TITLE-->/$title/" $outputFile 
fi

