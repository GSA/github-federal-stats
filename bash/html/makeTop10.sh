echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 || -z $5 || -z $6 || -z $7 || -z $8 || -z $8 ) ]]; then
  echo "Usage: makeBarChart.sh [configReader] [configFile] [outputFile] [mappingFile] [title] [element name] [ranking factor name] [range] [raw data]"
#element name is the content being ranked (i.e. a name)
#ranking factor is the criteria being used for the ranking (i.e. an update date)
else
  configReader=$1
  configFile=$2
  outputFile=$3
  mappingFile=$4
  title=$5
  element=$6
  rankingfactor=$7
  range=$8
  original=$(basename $9)

#echo "elementy:$element"
#echo "rankingfactor:$rankingfactor"

  
  scriptsDirectory=`$configReader $configFile scriptsDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`

  topTenTemp=$outputTempDirectory/topTen.html.temp
  cp $scriptsDirectory/html/topTen.template $outputFile

  head -n$range $mappingFile > $outputTempDirectory/topTenmapping.temp

  x=0
  echo "$title<br><br>" > $topTenTemp
  while read -r entry
  do
    x=$((x+1))	
    theElement=$(echo $entry | awk -F':' '{print $2 }')
    theRankingFactor=$(echo $entry | awk -F':' '{print $1 }')
# echo "the ranking factor: $theRankingFactor"
    if [ ! -z $(echo "$theRankingFactor" | grep "^[0-9]*\.\?[0-9]*$") ]; then
     # echo "truncating $theRankingFactor"
      theRankingFactor=`printf "%0.2f\n" $theRankingFactor`
    fi
#need to correct this to allow other hrefs...
    echo "<tr><td headers='ID'>$x</td><td headers='$element'><a href='https://github.com/$theElement'>$theElement</a></td><td headers='$rankingfactor'>$theRankingFactor</td></tr>" >> $topTenTemp
  done < $outputTempDirectory/topTenmapping.temp

  echo "inserting top Ten data into template at $outputFile"
  $scriptsDirectory/parseData/insertDataIntoTemplate.sh $outputFile $topTenTemp "<!--TOPTEN1-->"

  sed -i "s/<!--PAGE TITLE-->/$title/" $outputFile 
  sed -i "s/<!--RANKING FACTOR-->/$rankingfactor/" $outputFile 
  sed -i "s/<!--ELEMENT-->/$element/" $outputFile 

  sed -i "s/<!--RAWDATA-->/$original/" $outputFile 
fi

