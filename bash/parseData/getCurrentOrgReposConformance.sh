echo "enter $0"

file=$1
  configReader=$2
  configFile=$3
  token=$4
  org=$5
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  outputGHDirectory=`$configReader $configFile outputGHDirectory`
  outputReportDirectory=`$configReader $configFile outputReportDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`
  scriptsDirectory=`$configReader $configFile scriptsDirectory`

sed -n '/description":/,/"fork"/p' $file | sed -rn 's/.*description": "//;s/",.*//p' > $outputDataDirectory/orgs/"$org"projectDescriptions.txt
cat $outputDataDirectory/orgs/"$org"projectDescriptions.txt >> $outputDataDirectory/projectDescriptions.txt

averageWatchers=`$scriptsDirectory/parseData/getReposAverage.sh $file watchers`
averageIssues=`$scriptsDirectory/parseData/getReposAverage.sh $file open_issues`
sed -n '/full_name/p' $file | sed -rn 's/"full_name": "//;s/",//p' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' > $outputTempDirectory/projects.txt
averageProjCommits=$((0))

projCount=`cat $outputTempDirectory/projects.txt | wc -l`
projCount=$((projCount + 0))
if [ $projCount -eq 0 ]; then
  echo "project count is zero.  setting other values to zero."
  missingDescriptions=$((0))
  averageWatchers=$((0))
  averageIssues=$((0))
  averageCommits=$((0))
else
  #loop through project repos for an org
  while read -r line
  do
    #echo "scriptsDirectory=$scriptsDirectory"
    temp=`$scriptsDirectory/retrieveData/pullWeeklyCommits.sh $token $line`
    echo "$line : $temp"
    echo "$temp:$line" >> $outputDataDirectory/commitActivity.txt
    if [[ (! $temp = "") ]]; then
      averageProjCommits=$(awk "BEGIN {print $averageProjCommits+$temp; exit}")
    fi

    #add to file containing creation dates
    createdAt=`$scriptsDirectory/parseData/getReposField.sh $configReader $configFile $outputDataDirectory/orgs/"$org"FederalRepos.txt $line created_at`
    echo "$createdAt:$line"
    echo "$createdAt:$line" >> $outputDataDirectory/creationDates.txt 
  done < "$outputTempDirectory/projects.txt"

  ttlProjects=`cat $outputDataDirectory/orgs/"$org"projectDescriptions.txt | wc -l`
  ttlProjects=$((ttlProjects+0)) 

  averageCommits=$(awk "BEGIN {print $averageProjCommits/$ttlProjects; exit}")
  
  ttlDescriptions=`sed '/^\s*$/d' $outputDataDirectory/orgs/"$org"projectDescriptions.txt | wc -l`
  ttlDescriptions=$((ttlDescriptions+0)) 

  missingDescriptions=$((ttlProjects-$ttlDescriptions)) 
fi

echo "$missingDescriptions" > $outputDataDirectory/currentStats.txt

echo "<missingDescriptions>$missingDescriptions</missingDescriptions>" > $outputDataDirectory/currentStatsXML.txt
echo "<averageWatchers>$averageWatchers</averageWatchers>" >> $outputDataDirectory/currentStatsXML.txt
echo "<averageIssues>$averageIssues</averageIssues>" >> $outputDataDirectory/currentStatsXML.txt
echo "<averageCommits>$averageCommits</averageCommits>" >> $outputDataDirectory/currentStatsXML.txt

echo "<td>$missingDescriptions</td>" > $outputDataDirectory/currentStatsHTML.txt

#round for html display
averageWatchers2=`printf "%0.2f\n" $averageWatchers`
averageIssues2=`printf "%0.2f\n" $averageIssues`
averageCommits2=`printf "%0.2f\n" $averageCommits`

echo "<td>$averageWatchers2</td>" >> $outputDataDirectory/currentStatsHTML.txt
echo "<td>$averageIssues2</td>" >> $outputDataDirectory/currentStatsHTML.txt
echo "<td>$averageCommits2</td>" >> $outputDataDirectory/currentStatsHTML.txt
echo "exit $0"