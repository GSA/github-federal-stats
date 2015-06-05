echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 ) ]]; then
  echo "Usage: calculateTotals.sh [token] [configReader] [configFile]"
else
  token=$1
  configReader=$2
  configFile=$3
  scriptsDirectory=`$configReader $configFile scriptsDirectory`
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  outputGHDirectory=`$configReader $configFile outputGHDirectory`
  outputReportDirectory=`$configReader $configFile outputReportDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`

  orgIndex=$outputDataDirectory/federalOrgs.txt

  ttlOrgs=`cat $orgIndex | wc -l`
  ttlOrgs=$((ttlOrgs + 0))

  echo "Total Federal Organizations,$ttlOrgs"
  echo "Total Federal Organizations,$ttlOrgs" > $outputDataDirectory/stats.txt
  echo "<tr><td>Total Federal Organizations</td><td align=\"right\">$ttlOrgs</td></tr>" > $outputDataDirectory/htmlstats.txt

  $scriptsDirectory/parseData/getDescriptions.sh $configReader $configFile
  #$scriptsDirectory/parseData/getReposTtls.sh  $configReader $configFile description
  $scriptsDirectory/parseData/frequency.sh  $configReader $configFile $outputDataDirectory/projectDescriptions.txt $outputReportDirectory projectDescriptions

  `tr '\r' '\n' < $scriptsDirectory/parseData/stop-word-list.txt | grep -vwFf - $outputReportDirectory/frequencyProjectDescriptions.txt > $outputReportDirectory/frequencyProjectDescriptionsFiltered.txt`

  echo "checking languages"
  languages=`$scriptsDirectory/parseData/getReposTtls.sh  $configReader $configFile language $outputDataDirectory/languages.txt`
  $scriptsDirectory/parseData/frequency.sh  $configReader $configFile $outputDataDirectory/languages.txt $outputReportDirectory languages

  echo "checking creation times"
  cat $outputDataDirectory/creationDates.txt | sort -rn > $outputReportDirectory/sortedCreationDates.txt
  $scriptsDirectory/parseData/groupCreationDates.sh $outputReportDirectory/sortedCreationDates.txt $outputReportDirectory/groupedCreationDates

  echo "creating sorted commit averages file"
  sort -t\: -k1,1nr $outputDataDirectory/commitActivity.txt > $outputReportDirectory/mostActiveRepos.txt
fi
echo -e "---------------exit $0---------------"
