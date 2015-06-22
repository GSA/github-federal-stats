echo -e "\n---------------enter $0---------------"
  configReader=$1
  configFile=$2
  outputGHDirectory=`$configReader $configFile outputGHDirectory`
  outputReportDirectory=`$configReader $configFile outputReportDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  scriptsDirectory=`$configReader $configFile scriptsDirectory`

#this is in this file to do a count...
ttlProjects=`$scriptsDirectory/parseData/getReposTtls.sh  $configReader $configFile description $outputDataDirectory/stats.txt`
#just going to ignore totals file and overwrite it
echo "Total projects,$ttlProjects" >> $outputDataDirectory/stats.txt
echo "<tr><td>Total Project Repositories</td><td align=\"right\">$ttlProjects</td></tr>" >> $outputDataDirectory/htmlstats.txt

ttlDescriptions=`sed '/^\s*$/d' $outputDataDirectory/projectDescriptions.txt | wc -l`
ttlDescriptions=$((ttlDescriptions+0)) 
echo "Total projects with Descriptions,$ttlDescriptions" >> $outputDataDirectory/stats.txt
echo "<tr><td>Total Project Repositories with Descriptions</td><td align=\"right\">$ttlDescriptions</td></tr>" >> $outputDataDirectory/htmlstats.txt

missingDescriptions=$((ttlProjects-$ttlDescriptions)) 
echo "Total projects without Descriptions,$missingDescriptions" >> $outputDataDirectory/stats.txt
echo "<tr><td>Total Project Repositories without Descriptions</td><td align=\"right\">$missingDescriptions</td></tr>" >> $outputDataDirectory/htmlstats.txt

ttlReleases=`sed '/^\s*$/d' $outputDataDirectory/releases.txt | wc -l`

ttlPOCLines=`sed '/*$/d' $outputDataDirectory/pocs.txt | wc -l`
ttlPOCLines=$((ttlPOCLines-1))
ttlPOCs=`sed -n '/[^[:space:]]/p' $outputDataDirectory/pocs.txt | wc -l`
ttlPOCS=$((ttlPOCs+0))

descPerc=$((ttlDescriptions*100/ttlProjects))
releasePerc=$((ttlReleases*100/ttlProjects))
pocsPerc=$((ttlPOCS*100/ttlPOCLines))

cp -R $scriptsDirectory/html/jquery-circle-progress $outputReportDirectory

echo "ttlPOCs:$ttlPOCS"
echo "ttlPOCLines:$ttlPOCLines"
echo "pocsPerc:$pocsPerc"
$scriptsDirectory/html/makeCirclePage.sh $configReader $configFile $outputTempDirectory/overview.html $pocsPerc $descPerc $releasePerc

echo "inserting overview data into web page template"

#replace overview in orgHTML
orgHTML=$outputReportDirectory/index.html

$scriptsDirectory/parseData/insertDataIntoTemplate.sh $outputReportDirectory/index.html $outputTempDirectory/overview.html "<!--CIRCLE1-->"

echo -e "---------------exit $0---------------"
