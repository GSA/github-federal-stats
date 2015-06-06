echo "enter $0"
  configReader=$1
  configFile=$2
  outputGHDirectory=`$configReader $configFile outputGHDirectory`
  outputReportDirectory=`$configReader $configFile outputReportDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  scriptsDirectory=`$configReader $configFile scriptsDirectory`

#this is in this file to do a count...
ttlProjects=`$scriptsDirectory/parseData/getReposTtls.sh  $configReader $configFile description $outputDirectory/stats.txt`
#just going to ignore totals file and overwrite it
echo "Total projects,$ttlProjects" >> $outputDataDirectory/stats.txt
echo "<tr><td>Total Projects</td><td>$ttlProjects</td></tr>" >> $outputDataDirectory/htmlstats.txt

#echo "checking descriptions"
#echo "$outputDataDirectory/projectDescriptions.txt"
ttlDescriptions=`sed '/^\s*$/d' $outputDataDirectory/projectDescriptions.txt | wc -l`
ttlDescriptions=$((ttlDescriptions+0)) 
echo "Total projects with Descriptions,$ttlDescriptions" >> $outputDataDirectory/stats.txt
echo "<tr><td>Total Projects with Descriptions</td><td>$ttlDescriptions</td></tr>" >> $outputDataDirectory/htmlstats.txt

#echo "checking missing descriptions"
missingDescriptions=$((ttlProjects-$ttlDescriptions)) 
echo "Total projects without Descriptions,$missingDescriptions" >> $outputDataDirectory/stats.txt
echo "<tr><td>Total Projects without Descriptions</td><td>$missingDescriptions</td></tr>" >> $outputDataDirectory/htmlstats.txt

ttlPOCLines=`sed '/*$/d' $outputDataDirectory/pocs.txt | wc -l`
ttlPOCLines=$((ttlPOCLines-1))
ttlPOCs=`sed -n '/[^[:space:]]/p' $outputDataDirectory/pocs.txt | wc -l`
ttlPOCS=$((ttlPOCs+0))

descPerc=$((ttlDescriptions*100/ttlProjects))
pocsPerc=$((ttlPOCS*100/ttlPOCLines))
cp -R $scriptsDirectory/html/jquery-circle-progress $outputReportDirectory

#echo "missingPOCs:$missingPOCs"
echo "ttlPOCs:$ttlPOCS"
echo "ttlPOCLines:$ttlPOCLines"
echo "pocsPerc:$pocsPerc"
$scriptsDirectory/html/makeCirclePage.sh $configReader $configFile $outputReportDirectory/overview.html $pocsPerc $descPerc

echo "exit $0"
