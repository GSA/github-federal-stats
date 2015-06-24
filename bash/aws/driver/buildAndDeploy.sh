echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 || -z $5 || -z $6 || -z $7 ) ]]; then
  echo "Usage: buildAndDeploy.sh [rootDirectory] [outputDirectory] [user.email] [buildToken] [deployToken] [iopage] [refresh]"
else
  rootDirectory=$1
  outputDirectory=$2
  user=$3
  buildtoken=$4
  deploytoken=$5
  iopage=$6
  refresh=$7
  $rootDirectory/aws/driver/buildAll.sh $rootDirectory $outputDirectory $buildtoken $refresh
  $rootDirectory/aws/driver/deployGHP.sh $outputDirectory $user $deploytoken $iopage
fi
echo -e "\n---------------exit $0---------------"
