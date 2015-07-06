echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 || -z $5 || -z $6 ) ]]; then
  echo "Usage: buildAgency.sh [rootDirectory] [outputDirectory] [wwwDirectory] [buildToken] [refresh] [agency]"
else
  rootDirectory=$1
  outputDirectory=$2
  wwwDirectory=$3
  buildToken=$4
  refresh=$5
  agency=$6

  if [[ ( $refresh = "true" ) ]]; then
    $rootDirectory/buildGitHubIndex.sh $buildToken $rootDirectory/control/getConfigElement.sh $rootDirectory/defaultConfigRefresh.txt true $agency 2>&1 | tee $outputDirectory/alloutput.log
  else
    $rootDirectory/buildGitHubIndex.sh $buildToken $rootDirectory/control/getConfigElement.sh $rootDirectory/defaultConfigCache.txt $agency false 2>&1 | tee $outputDirectory/alloutput.log
  fi
  cp -R $outputDirectory/publish/$agency/ $wwwDirectory
fi
echo -e "\n---------------exit $0---------------"
