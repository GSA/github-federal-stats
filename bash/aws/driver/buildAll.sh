echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 ) ]]; then
  echo "Usage: buildAll.sh [rootDirectory] [buildToken] [refresh]"
else
  rootDirectory=$1
  buildToken=$2
  refresh=$3

  if [[ ( $refresh = "true" ) ]]; then
    $rootDirectory/buildGitHubIndex.sh $buildToken $rootDirectory/control/getConfigElement.sh $rootDirectory/allConfigRefresh.txt true 2>&1 | tee $rootDirectory/alloutput.log
  else
    $rootDirectory/buildGitHubIndex.sh $buildToken $rootDirectory/control/getConfigElement.sh $rootDirectory/allConfigCache.txt false 2>&1 | tee $rootDirectory/alloutput.log
  fi
  cp -R $rootDirectory/output/publish/all/ /var/www/html/
fi
echo -e "\n---------------exit $0---------------"
