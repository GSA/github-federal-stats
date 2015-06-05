echo -e "\n---------------enter $0---------------"
  configReader=$1
  configFile=$2
  outputGHDirectory=`$configReader $configFile outputGHDirectory`
  outputReportDirectory=`$configReader $configFile outputReportDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  scriptsDirectory=`$configReader $configFile scriptsDirectory`


outputFile=$3
pocs=$4
descrips=$5

#echo "------descrips=$descrips----------------------------"

$scriptsDirectory/html/createCircle.sh $scriptsDirectory/html/circles.middle $outputTempDirectory/circles1.middle circle1 'Organization<br>POC' $pocs
$scriptsDirectory/html/createCircle.sh $scriptsDirectory/html/circles.middle $outputTempDirectory/circles2.middle circle2 'Repository<br>Descriptions' $descrips 
#cat $scriptsDirectory/html/circles.top > $outputFile
cat $outputTempDirectory/circles1.middle > $outputFile
cat $outputTempDirectory/circles2.middle >> $outputFile

echo '<HR noshade style="color:#CCC; width:250px">' >> $outputFile
echo '<P></P>' >> $outputFile
echo '<table width="250">' >> $outputFile

cat $outputDataDirectory/htmlstats.txt >> $outputFile

echo '</table><br>' >> $outputFile
echo '<HR noshade style="color:#CCC; width:250px">' >> $outputFile


#cat $scriptsDirectory/html/circles.bottom >> $outputFile

timestamp=`date +"%m/%d/%y at %H:%M"`

echo "<br><small>Report Generated on $timestamp</small>" >> $outputFile
#echo "</body></html>" >> $outputFile
echo -e "---------------exit $0---------------"