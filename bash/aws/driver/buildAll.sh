echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 ) ]]; then
  echo "Usage: buildAll.sh [rootDirectory] [buildToken] [refresh:optional(default false)]"
else
  rootDirectory=$1
  buildToken=$2
  if [[ ( -z $3 ) ]]; then
    refresh="false"
  else
    if [[ ! ( $3 = "true" || $3 = "false" ) ]]; then
      refresh="false"
    else
      refresh=$4
    fi
  fi

  if [[ ( $refresh = "true" ) ]]; then
    $rootDirectory/buildGitHubIndex.sh $buildToken $rootDirectory/control/getConfigElement.sh $rootDirectory/allConfigRefresh.txt true 2>&1 | tee $rootDirectory/alloutput.log
  else
    $rootDirectory/buildGitHubIndex.sh $buildToken $rootDirectory/control/getConfigElement.sh $rootDirectory/allConfigCache.txt true 2>&1 | tee $rootDirectory/alloutput.log
  fi
  cp -R $rootDirectory/output/publish/all/ /var/www/html/
fi
echo -e "\n---------------exit $0---------------"
