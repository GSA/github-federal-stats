echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 || -z $5 || -z $6 || -z $7 ) ]]; then
  echo "Usage: buildAndDeploy.sh [rootDirectory] [outputDirectory] [user.email] [buildToken] [deployToken] [iopage] [refresh] [optional:agency]"
else
  rootDirectory=$1
  outputDirectory=$2
  user=$3
  buildtoken=$4
  deploytoken=$5
  iopage=$6
  refresh=$7
  if [ -n $8 ]; then
    $rootDirectory/aws/driver/buildAgency.sh $rootDirectory $outputDirectory $buildtoken $refresh $8
  $rootDirectory/aws/driver/deployGHP.sh $outputDirectory $user $deploytoken $iopage $agency
  else
    $rootDirectory/aws/driver/buildAll.sh $rootDirectory $outputDirectory $buildtoken $refresh
  $rootDirectory/aws/driver/deployGHP.sh $outputDirectory $user $deploytoken $iopage
  fi 
fi
echo -e "\n---------------exit $0---------------"
