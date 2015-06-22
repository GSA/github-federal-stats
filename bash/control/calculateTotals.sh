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

  echo "checking project releases"
  ttlReleases=`cat $outputDataDirectory/releases.txt | wc -l`
  ttlReleases=$((ttlReleases + 0))

  echo "Total Federal Organizations,$ttlOrgs"
  echo "Total Federal Organizations,$ttlOrgs" > $outputDataDirectory/stats.txt
  echo "<tr><td>Total Federal Organizations</td><td align=\"right\">$ttlOrgs</td></tr>" > $outputDataDirectory/htmlstats.txt

  $scriptsDirectory/parseData/getDescriptions.sh $configReader $configFile

  echo "checking project Descriptions"
  $scriptsDirectory/parseData/frequency.sh  $configReader $configFile $outputDataDirectory/projectDescriptions.txt $outputReportDirectory ProjectDescriptions

  `tr '\r' '\n' < $scriptsDirectory/parseData/stop-word-list.txt | grep -vwFf - $outputReportDirectory/frequencyProjectDescriptions.txt > $outputReportDirectory/frequencyProjectDescriptionsFiltered.txt`

  echo "checking languages"
  languages=`$scriptsDirectory/parseData/getReposTtls.sh  $configReader $configFile language $outputDataDirectory/languages.txt`
  $scriptsDirectory/parseData/frequency.sh  $configReader $configFile $outputDataDirectory/languages.txt $outputReportDirectory languages

  echo "checking creation times"
  cat $outputDataDirectory/creationDates.txt | sort -rn > $outputReportDirectory/sortedCreationDates.txt
  sed -i '/^$/d' $outputReportDirectory/sortedCreationDates.txt
  sed -i 's/\(.*\)T.*\(:.*\)/\1\2/' $outputReportDirectory/sortedCreationDates.txt
  $scriptsDirectory/parseData/groupCreationDates.sh $outputReportDirectory/sortedCreationDates.txt $outputReportDirectory/groupedCreationDates

  echo "inserting 2 week data into bar chart page template"
#  $scriptsDirectory/parseData/fillInBlankDates.sh $scriptsDirectory/output/publish/all/groupedCreationDatesDaily.txt $outputReportDirectory/groupedCreationDatesDailyLatest.txt D 14
  $scriptsDirectory/parseData/fillInBlankDates.sh $outputReportDirectory/groupedCreationDatesDaily.txt $outputReportDirectory/groupedCreationDatesDailyLatest.txt D 14
  $scriptsDirectory/html/makeChart.sh $configReader $configFile $scriptsDirectory/html/barChart.template $outputReportDirectory/day.html $outputReportDirectory/groupedCreationDatesDailyLatest.txt "New Project Repositories Over the Past 14 Days" 14 backward $outputReportDirectory/groupedCreationDatesDaily.txt

  echo "inserting 12 month data into bar chart page template"
#  $scriptsDirectory/parseData/fillInBlankDates.sh $scriptsDirectory/output/publish/all/groupedCreationDatesMonthly.txt $outputReportDirectory/groupedCreationDatesMonthlyLatest.txt M 12
  $scriptsDirectory/parseData/fillInBlankDates.sh $outputReportDirectory/groupedCreationDatesMonthly.txt $outputReportDirectory/groupedCreationDatesMonthlyLatest.txt M 12
  $scriptsDirectory/html/makeChart.sh $configReader $configFile $scriptsDirectory/html/barChart.template $outputReportDirectory/month.html $outputReportDirectory/groupedCreationDatesMonthlyLatest.txt "New Project Repositories Over the Past 12 Months" 12 backward $outputReportDirectory/groupedCreationDatesMonthly.txt

  echo "inserting year data into bar chart page template"
#  $scriptsDirectory/parseData/fillInBlankDates.sh $scriptsDirectory/output/publish/all/groupedCreationDatesYearly.txt $outputReportDirectory/groupedCreationDatesYearlyLatest.txt Y 10
  $scriptsDirectory/parseData/fillInBlankDates.sh $outputReportDirectory/groupedCreationDatesYearly.txt $outputReportDirectory/groupedCreationDatesYearlyLatest.txt Y 10
  $scriptsDirectory/html/makeChart.sh $configReader $configFile $scriptsDirectory/html/barChart.template $outputReportDirectory/year.html $outputReportDirectory/groupedCreationDatesYearlyLatest.txt "New Project Repositories by Year" 10 backward $outputReportDirectory/groupedCreationDatesYearly.txt


  echo "inserting language data into pie chart page template"
#  $scriptsDirectory/parseData/groupEntriesForPieOther.sh $scriptsDirectory/output/publish/all/frequencylanguages.txt $outputReportDirectory/frequencylanguagestop.txt 10
  $scriptsDirectory/parseData/groupEntriesForPieOther.sh $outputReportDirectory/frequencylanguages.txt $outputReportDirectory/frequencylanguagestop.txt 10
  $scriptsDirectory/html/makeChart.sh $configReader $configFile $scriptsDirectory/html/pieChart.template $outputReportDirectory/language.html $outputReportDirectory/frequencylanguagestop.txt "Top Project Repository Programming Languages" 10 forward $outputReportDirectory/frequencylanguages.txt


  echo "inserting word count data into pie chart page template"
#  $scriptsDirectory/parseData/groupEntriesForPieOther.sh $scriptsDirectory/output/publish/all/frequencyProjectDescriptionsFiltered.txt $outputReportDirectory/frequencyProjectDescriptionsFilteredtop.txt 15 50
  $scriptsDirectory/parseData/groupEntriesForPieOther.sh $outputReportDirectory/frequencyProjectDescriptionsFiltered.txt $outputReportDirectory/frequencyProjectDescriptionsFilteredtop.txt 15 50
  $scriptsDirectory/html/makeChart.sh $configReader $configFile $scriptsDirectory/html/pieChart.template $outputReportDirectory/word.html $outputReportDirectory/frequencyProjectDescriptionsFilteredtop.txt "Top 50 Words Used in Project Repository Descriptions" 15 forward $outputReportDirectory/frequencyProjectDescriptionsFiltered.txt






  echo "creating top 20 newest repositories"
  $scriptsDirectory/html/makeTop10.sh $configReader $configFile $outputReportDirectory/newest.html $outputReportDirectory/sortedCreationDates.txt "20 Newest Project Repositories" "Repository" "Creation Date" 20 $outputReportDirectory/sortedCreationDates.txt

  echo "creating sorted commit averages file"
  sed -i '/^$/d' $outputDataDirectory/commitActivity.txt
  sort -t\: -k1,1nr $outputDataDirectory/commitActivity.txt > $outputReportDirectory/mostActiveRepos.txt
#  sort -t\: -k1,1nr $scriptsDirectory/output/data/all/commitActivity.txt > $outputReportDirectory/mostActiveRepos.txt

  echo "creating top 20 most active repositories"
  $scriptsDirectory/html/makeTop10.sh $configReader $configFile $outputReportDirectory/mostactive.html $outputReportDirectory/mostActiveRepos.txt "20 Most Active Project Repositories" "Repository" "Commits per Week over 52 Weeks" 20 $outputReportDirectory/mostActiveRepos.txt
#  $scriptsDirectory/html/makeTop10.sh $configReader $configFile $outputReportDirectory/mostactive.html $scriptsDirectory/output/publish/all/mostActiveRepos.txt "20 Most Active Project Repositories" "Repository" "Commits per Week over 52 Weeks" 20 $outputReportDirectory/mostActiveRepos.txt
fi
echo -e "---------------exit $0---------------"
