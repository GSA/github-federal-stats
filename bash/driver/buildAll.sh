echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 || -z $5 ) ]]; then
  echo "Usage: buildAll.sh [rootDirectory] [outputDirectory] [wwwDirectory] [buildToken] [refresh]"
else
  rootDirectory=$1
  outputDirectory=$2
  wwwDirectory=$3
  buildToken=$4
  refresh=$5

  if [[ ( $refresh = "true" ) ]]; then
    $rootDirectory/buildGitHubIndex.sh $buildToken $rootDirectory/control/getConfigElement.sh $rootDirectory/allConfigRefresh.txt true 2>&1 | tee $outputDirectory/alloutput.log
  else
    $rootDirectory/buildGitHubIndex.sh $buildToken $rootDirectory/control/getConfigElement.sh $rootDirectory/allConfigCache.txt false 2>&1 | tee $outputDirectory/alloutput.log
  fi
  cp -R $outputDirectory/publish/all/ $wwwDirectory
fi
echo -e "\n---------------exit $0---------------"
