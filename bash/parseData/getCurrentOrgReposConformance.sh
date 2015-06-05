echo -e "\n---------------enter $0---------------"

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

  descriptionHTMLTemp=$outputTempDirectory/descriptionTemp.html

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
  echo "looping through project repositories for $org"

  while read -r line
  do
    echo "line is $line"
    reposDirectory=$outputDataDirectory/orgs/"$line"
    refresh=`$scriptsDirectory/retrieveData/checkRetrievalFlag.sh $configReader $configFile refreshGitHubCommitsInfo $reposDirectory/weeklyStats.txt`

  if [[ ( $refresh = "true" ) ]]; then
    $scriptsDirectory/retrieveData/pullWeeklyCommits.sh $token $configReader $configFile $line
  fi
  #  temp=`cat $reposDirectory/weeklyStats.txt | sed '1,/all/d;/\]/,$d' | sed 's/,$//' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | awk '{ total += $1; count++ } END { if (count > 0 ) print total/count; else print 0 }'`
    temp=`cat $reposDirectory/weeklyStatsAverage.txt`

    echo "$line : $temp"
    echo "$temp:$line" >> $outputDataDirectory/commitActivity.txt

    if [[ (! $temp = "") ]]; then
       averageProjCommits=$(awk "BEGIN {print $averageProjCommits+$temp; exit}")
    fi

    #add to file containing creation dates
    createdAt=`$scriptsDirectory/parseData/getReposField.sh $configReader $configFile $outputDataDirectory/orgs/"$org"FederalRepos.txt $line created_at`
    echo "$createdAt:$line"
    echo "$createdAt:$line" >> $outputDataDirectory/creationDates.txt 

    echo "getting description"
    description=`cat $reposDirectory/description.txt`
    if [ -z "$description" ]; then
      description=`$scriptsDirectory/parseData/getReposField.sh $configReader $configFile $outputDataDirectory/orgs/"$org"FederalRepos.txt $line description`
      if [ -z "$description" ]; then
        description="--"
      fi    
      echo $description > $reposDirectory/description.txt
    fi

    echo "getting language"
    language=`cat $reposDirectory/language.txt`
    if [ -z "$language" ]; then
      language=`$scriptsDirectory/parseData/getReposField.sh $configReader $configFile $outputDataDirectory/orgs/"$org"FederalRepos.txt $line language`
      if [ -z "$language" ]; then
        language="--"
      fi
      echo $description > $reposDirectory/language.txt
    fi

    echo "<tr><td headers="Description">$description</td><td headers="Language">$language</td><td headers="Project"><a href=\"https://github.com/$line\">$line</a></td></tr>" >> $descriptionHTMLTemp
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

echo "<td headers='Missing_Descriptions'>$missingDescriptions</td>" > $outputDataDirectory/currentStatsHTML.txt

#round for html display
averageWatchers2=`printf "%0.2f\n" $averageWatchers`
averageIssues2=`printf "%0.2f\n" $averageIssues`
averageCommits2=`printf "%0.2f\n" $averageCommits`

echo "<td headers='Average_Watchers'>$averageWatchers2</td>" >> $outputDataDirectory/currentStatsHTML.txt
echo "<td headers='Average_Issues'>$averageIssues2</td>" >> $outputDataDirectory/currentStatsHTML.txt
echo "<td headers='Average_Commits'>$averageCommits2</td>" >> $outputDataDirectory/currentStatsHTML.txt
echo -e "---------------exit $0---------------"