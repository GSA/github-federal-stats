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
  sed -i '/^$/d' $outputReportDirectory/sortedCreationDates.txt
  $scriptsDirectory/parseData/groupCreationDates.sh $outputReportDirectory/sortedCreationDates.txt $outputReportDirectory/groupedCreationDates

  echo "inserting 2 week data into bar chart page template"
#  $scriptsDirectory/html/makeBarChart.sh $configReader $configFile $outputReportDirectory/day.html $outputReportDirectory/groupedCreationDatesDaily.txt "New GitHub Repositories Over the Past 14 Days" 14
  $scriptsDirectory/html/makeBarChart.sh $configReader $configFile $outputReportDirectory/day.html $scriptsDirectory/output/publish/all/groupedCreationDatesDaily.txt "New GitHub Repositories Over the Past 14 Days" 14

  echo "inserting 12 month data into bar chart page template"
#  $scriptsDirectory/html/makeBarChart.sh $configReader $configFile $outputReportDirectory/month.html $outputReportDirectory/groupedCreationDatesMonthly.txt "New GitHub Repositories Over the Past 12 Months" 12
  $scriptsDirectory/html/makeBarChart.sh $configReader $configFile $outputReportDirectory/month.html $scriptsDirectory/output/publish/all/groupedCreationDatesMonthly.txt "New GitHub Repositories Over the Past 12 Months" 12

  echo "inserting 12 month data into bar chart page template"
#  $scriptsDirectory/html/makeBarChart.sh $configReader $configFile $outputReportDirectory/year.html $outputReportDirectory/groupedCreationDatesYearly.txt "New GitHub Repositories by Year" 10
  $scriptsDirectory/html/makeBarChart.sh $configReader $configFile $outputReportDirectory/year.html $scriptsDirectory/output/publish/all/groupedCreationDatesYearly.txt "New GitHub Repositories by Year" 10

  echo "creating top 20 newest repositories"
  $scriptsDirectory/html/makeTop10.sh $configReader $configFile $outputReportDirectory/newest.html $scriptsDirectory/output/publish/all/sortedCreationDates.txt "Newest 20 Repositories" 20

  echo "creating sorted commit averages file"
  sort -t\: -k1,1nr $outputDataDirectory/commitActivity.txt > $outputReportDirectory/mostActiveRepos.txt
fi
echo -e "---------------exit $0---------------"
