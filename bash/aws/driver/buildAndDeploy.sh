echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 || -z $5 || -z $6 ) ]]; then
  echo "Usage: buildAndDeploy.sh [rootDirectory] [user.email] [buildToken] [deployToken] [iopage] [refresh]"
else
  rootDirectory=$1
  user=$2
  buildtoken=$3
  deploytoken=$4
  iopage=$5
  refresh=$6

  ./buildAll.sh $rootDirectory $buildToken $refresh
  ./deployGHP.sh $rootDirectory $user $deploytoken $iopage
fi
echo -e "\n---------------exit $0---------------"
