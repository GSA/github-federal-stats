echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 ) ]]; then
  echo "Usage: pullReleases.sh [token] [configReader] [configFile] [org]"
else
  configReader=$2
  configFile=$3
  org=$4
echo "org is $org"

  scriptsDirectory=`$configReader $configFile scriptsDirectory`
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  outputSharedDataDirectory=`$configReader $configFile outputSharedDataDirectory`
#  outputGHDirectory=`$configReader $configFile outputGHDirectory`
#  outputReportDirectory=`$configReader $configFile outputReportDirectory`
#  outputTempDirectory=`$configReader $configFile outputTempDirectory`

  currentOrg=$outputSharedDataDirectory/orgs/"$org"
#WeeklyCommits.txt
  if [ ! -d "$currentOrg" ]; then
    echo "making $currentOrg directory."
    mkdir -p $currentOrg
  fi
  refresh=`$scriptsDirectory/retrieveData/checkRetrievalFlag.sh $configReader $configFile refreshGitHubCommitsInfo  $outputSharedDataDirectory/orgs/$org/releases.txt`

  echo "refresh for $org weekly releases info from GitHub =$refresh" 

  if [[ ( $refresh = "true" ) ]]; then
    echo "Retrieving $org info from GitHub"
    curl -s -H "Authorization: token $1" https://api.github.com/repos/$org/releases >  $outputSharedDataDirectory/orgs/$org/releases.txt
  fi
fi

echo -e "---------------exit $0---------------"



