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

  cd $rootDirectory
  if [[ ( $refresh = "true" ) ]]; then
    ./buildGitHubIndex.sh $buildToken ./control/getConfigElement.sh ./allConfigRefresh.txt true 2>&1 | tee alloutput.log
  else
    ./buildGitHubIndex.sh $buildToken ./control/getConfigElement.sh ./allConfigCache.txt true 2>&1 | tee alloutput.log
  fi
  cd ./output/publish/
  cp -R . /var/www/html/
fi
echo -e "\n---------------exit $0---------------"
