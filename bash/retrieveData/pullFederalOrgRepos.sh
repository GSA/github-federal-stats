
echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 ) ]]; then
  echo "Usage: pullFederalOrgInfo.sh [token] [configReader] [configFile] [org]"
else
  configReader=$2
  configFile=$3
  org=$4

  scriptsDirectory=`$configReader $configFile scriptsDirectory`
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  outputGHDirectory=`$configReader $configFile outputGHDirectory`
  outputReportDirectory=`$configReader $configFile outputReportDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`

  currentOrg=$outputDataDirectory/orgs/"$org"FederalRepos.txt
  refresh=`$scriptsDirectory/retrieveData/checkRetrievalFlag.sh $configReader $configFile refreshGitHubReposInfo $currentOrg`

  echo "refresh repos for $org from GitHub =$refresh" 
  if [[ ( $refresh = "true" ) ]]; then
    echo "Retrieving repos for $org from GitHub"
     curl -H "Authorization: token $1" https://api.github.com/search/repositories?q=user:$org > $currentOrg
  fi
fi
echo -e "---------------exit $0---------------"





