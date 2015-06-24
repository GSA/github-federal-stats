echo -e "\n---------------enter $0---------------"

  file=$1
  configReader=$2
  configFile=$3
  token=$4
  org=$5
  limit1=$((500))
  limit2=$((50))
  loopcheck=$((10))

#  outputDataDirectory=`$configReader $configFile outputDataDirectory`
#  outputTempDirectory=`$configReader $configFile outputTempDirectory`
#  scriptsDirectory=`$configReader $configFile scriptsDirectory`

  outputDataDirectory=$6
  outputTempDirectory=$7
  scriptsDirectory=$8
  outputSharedDataDirectory=$9

  descriptionHTMLTemp=$outputTempDirectory/descriptionTemp.html

sed -n '/description":/,/"fork"/p' $file | sed -rn 's/.*description": "//;s/",.*//p' > $outputSharedDataDirectory/orgs/"$org"projectDescriptions.txt
cat $outputSharedDataDirectory/orgs/"$org"projectDescriptions.txt >> $outputDataDirectory/projectDescriptions.txt

echo "entering getReposAverage.sh watchers"
averageWatchers=`$scriptsDirectory/parseData/getReposAverage.sh $file watchers`
echo "exiting getReposAverage.sh watchers"
echo "entering getReposAverage.sh open_issues"
averageIssues=`$scriptsDirectory/parseData/getReposAverage.sh $file open_issues`
echo "exiting getReposAverage.sh open_issues"
sed -n '/full_name/p' $file | sed -rn 's/"full_name": "//;s/",//p' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' > $outputTempDirectory/projects.txt
averageProjCommits=$((0))

projCount=`grep -c ^ $outputTempDirectory/projects.txt`
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
  count=0;

  while read -r line
  do
    echo "line is $line"
    count=$((count+1))
    echo "checking on $loopcheck call=$((count%loopcheck))"
    if  [[ $((count%loopcheck)) = 0 ]]; then
      echo "checking remaining queries against a lower limit of $limit2..."
      remaining=`$scriptsDirectory/retrieveData/rateLimitRemaining.sh $token`
      remaining=$((remaining+0))
      echo "$remaining remaining"
      if [ "$remaining" -lt "$limit1" ]; then
        loopcheck=$((1))
      fi
      if [ "$remaining" -lt "$limit2" ]; then
        secondstowait=`$scriptsDirectory/retrieveData/rateLimitSeconds.sh $token`
        echo "pausing $secondstowait to allow rate limit to reset..."

        sleep "$secondstowait"s
      fi
    fi

    reposDirectory=$outputSharedDataDirectory/orgs/"$line"
    refresh=`$scriptsDirectory/retrieveData/checkRetrievalFlag.sh $configReader $configFile refreshGitHubCommitsInfo $reposDirectory/weeklyStats.txt`

    if [[ ( $refresh = "true" ) ]]; then
      $scriptsDirectory/retrieveData/pullWeeklyCommits.sh $token $configReader $configFile $line
      $scriptsDirectory/retrieveData/pullReleases.sh $token $configReader $configFile $line
      $scriptsDirectory/retrieveData/pullContributors.sh $token $configReader $configFile $line
    fi
    temp=`cat $reposDirectory/weeklyStatsAverage.txt`

    echo "$line : $temp"
    echo "$temp:$line" >> $outputDataDirectory/commitActivity.txt

    if [[ (! $temp = "") ]]; then
       averageProjCommits=$(awk "BEGIN {print $averageProjCommits+$temp; exit}")
    fi

    #add to file containing creation dates
    createdAt=`$scriptsDirectory/parseData/getReposField.sh $outputSharedDataDirectory/orgs/"$org"FederalRepos.txt $line created_at`
    echo "$createdAt:$line"
    echo "$createdAt:$line" >> $outputDataDirectory/creationDates.txt 

    echo "getting description"
    refresh=`$scriptsDirectory/retrieveData/checkRetrievalFlag.sh $configReader $configFile refreshGitHubReposInfo $reposDirectory/description.txt`
    if [[ ( $refresh = "true" ) ]]; then
      description=`$scriptsDirectory/parseData/getReposField.sh $outputSharedDataDirectory/orgs/"$org"FederalRepos.txt $line description`
      if [ -z "$description" ]; then
        description="--"
      fi    

      if [ ! -d "$reposDirectory" ]; then
        echo "making $reposDirectory directory."
        mkdir -p $reposDirectory
      fi
      echo $description > $reposDirectory/description.txt
    else
      description=`cat $reposDirectory/description.txt`
    fi

    echo "getting language"

    refresh=`$scriptsDirectory/retrieveData/checkRetrievalFlag.sh $configReader $configFile refreshGitHubReposInfo $reposDirectory/languiage.txt`
    if [[ ( $refresh = "true" ) ]]; then
      language=`$scriptsDirectory/parseData/getReposField.sh $outputSharedDataDirectory/orgs/"$org"FederalRepos.txt $line language`
      if [ -z "$language" ]; then
        language="--"
      fi
      echo $language > $reposDirectory/language.txt
    else
      language=`cat $reposDirectory/language.txt`
    fi
echo "language=$language"

    echo "getting latest release"
    release=`grep -m 1 "html_url" $outputSharedDataDirectory/orgs/$line/releases.txt | awk -F "\"" '{print $4}'`
    if [[ "" == "$release" ]]; then
      latestRelease="--";
    else
      latestRelease="<a href='$release'>$release</a>"
      echo $latestRelease >> $outputDataDirectory/releases.txt
    fi

    echo "getting contributors"
    contributors=`grep "login" $outputSharedDataDirectory/orgs/$line/contributors.txt | wc -l`
#echo "cotributors in  $outputSharedDataDirectory/orgs/$line/contributors.txt =$contributors"
    echo "<tr><td headers='Project_Repository'><a href='https://github.com/$line'>$line</a></td><td headers='Language'>$language</td><td headers='Description'>$description</td><td>$latestRelease</td><td>$contributors</td></tr>" >> $descriptionHTMLTemp
  done < "$outputTempDirectory/projects.txt"

  ttlProjects=`grep -c ^ $outputSharedDataDirectory/orgs/"$org"projectDescriptions.txt`
  ttlProjects=$((ttlProjects+0)) 

  averageCommits=$(awk "BEGIN {print $averageProjCommits/$ttlProjects; exit}")
  
  ttlDescriptions=`sed '/^\s*$/d' $outputSharedDataDirectory/orgs/"$org"projectDescriptions.txt | wc -l`
  ttlDescriptions=$((ttlDescriptions+0)) 

  missingDescriptions=$((ttlProjects-$ttlDescriptions)) 
fi

echo "$missingDescriptions" > $outputDataDirectory/currentStats.txt

#echo "<missingDescriptions>$missingDescriptions</missingDescriptions>" > $outputDataDirectory/currentStatsXML.txt
#echo "<averageWatchers>$averageWatchers</averageWatchers>" >> $outputDataDirectory/currentStatsXML.txt
#echo "<averageIssues>$averageIssues</averageIssues>" >> $outputDataDirectory/currentStatsXML.txt
#echo "<averageCommits>$averageCommits</averageCommits>" >> $outputDataDirectory/currentStatsXML.txt

echo "<td headers='Missing_Descriptions'>$missingDescriptions</td>" > $outputDataDirectory/currentStatsHTML.txt

#round for html display
averageWatchers2=`printf "%0.2f\n" $averageWatchers`
averageIssues2=`printf "%0.2f\n" $averageIssues`
averageCommits2=`printf "%0.2f\n" $averageCommits`

echo "<td headers='Average_Watchers'>$averageWatchers2</td>" >> $outputDataDirectory/currentStatsHTML.txt
echo "<td headers='Average_Issues'>$averageIssues2</td>" >> $outputDataDirectory/currentStatsHTML.txt
echo "<td headers='Average_Commits'>$averageCommits2</td>" >> $outputDataDirectory/currentStatsHTML.txt
echo -e "---------------exit $0---------------"
