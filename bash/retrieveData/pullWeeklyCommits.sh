echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 ) ]]; then
  echo "Usage: pullWeeklyCommits.sh [token] [configReader] [configFile] [org]"
else
  configReader=$2
  configFile=$3
  org=$4
echo "org is $org"

  scriptsDirectory=`$configReader $configFile scriptsDirectory`
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  outputSharedDataDirectory=`$configReader $configFile outputDataDirectory`
#  outputGHDirectory=`$configReader $configFile outputGHDirectory`
#  outputReportDirectory=`$configReader $configFile outputReportDirectory`
#  outputTempDirectory=`$configReader $configFile outputTempDirectory`

  currentOrg=$outputSharedDataDirectory/orgs/"$org"
#WeeklyCommits.txt
  if [ ! -d "$currentOrg" ]; then
    echo "making $currentOrg directory."
    mkdir -p $currentOrg
  fi

  refresh=`$scriptsDirectory/retrieveData/checkRetrievalFlag.sh $configReader $configFile refreshGitHubCommitsInfo $currentOrg/weeklyStats.txt`

  echo "refresh for $org weekly commits info from GitHub =$refresh" 

  if [[ ( $refresh = "true" ) ]]; then
    echo "Retrieving $org info from GitHub"
    curl -s -H "Authorization: token $1" https://api.github.com/repos/$org/stats/participation > $currentOrg/weeklyStats.txt

    temp=`cat $currentOrg/weeklyStats.txt | sed '1,/all/d;/\]/,$d' | sed 's/,$//' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | awk '{ total += $1; count++ } END { if (count > 0 ) print total/count; else print 0 }'`
    echo $temp > $currentOrg/weeklyStatsAverage.txt
  fi
fi

echo -e "---------------exit $0---------------"



