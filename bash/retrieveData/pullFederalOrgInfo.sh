echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 ) ]]; then
  echo "Usage: pullFederalOrgInfo.sh [token] [org] [outputfile]"
else
  org=$2
  currentOrg=$3

  echo "Retrieving $org info from GitHub"
  curl -H "Authorization: token $1" https://api.github.com/users/$org > $currentOrg
fi
echo -e "---------------exit $0---------------"


