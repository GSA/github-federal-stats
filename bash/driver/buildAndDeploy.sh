echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 || -z $5 || -z $6 || -z $7 || -z $8 ) ]]; then
  echo "Usage: buildAndDeploy.sh [rootDirectory] [outputDirectory] [wwwDirectory] [user.email] [buildToken] [deployToken] [iopage] [refresh] [optional:agency]"
else
  rootDirectory=$1
  outputDirectory=$2
  wwwDirectory=$3
  user=$4
  buildtoken=$5
  deploytoken=$6
  iopage=$7
  refresh=$8
  if [[ ( -n $9 ) ]]; then
    $rootDirectory/driver/buildAgency.sh $rootDirectory $outputDirectory $wwwDirectory $buildtoken $refresh $9
  $rootDirectory/driver/deployGHP.sh $outputDirectory $user $deploytoken $iopage $9
  else
    $rootDirectory/driver/buildAll.sh $rootDirectory $outputDirectory $wwwDirectory $buildtoken $refresh
  $rootDirectory/driver/deployGHP.sh $outputDirectory $user $deploytoken $iopage all
  fi
fi
echo -e "\n---------------exit $0---------------"
