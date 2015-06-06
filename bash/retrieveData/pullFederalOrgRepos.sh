
echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 ) ]]; then
  echo "Usage: pullFederalOrgInfo.sh [token] [org] [outputFile]"
else
  org=$2
  currentOrg=$3

  echo "Retrieving repos for $org from GitHub"
  curl -H "Authorization: token $1" https://api.github.com/search/repositories?q=user:$org > $currentOrg
fi
echo -e "---------------exit $0---------------"





