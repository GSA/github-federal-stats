
echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 ) ]]; then
  echo "Usage: pullFederalOrgInfo.sh [token] [org] [outputFile]"
else
  org=$2
  currentOrg=$3
echo > $currentOrg
  theURL="https://api.github.com/search/repositories?q=user:$org&per_page=100&page"

  echo "checking the number of pages for repos API call"
  pages=`curl -Is "$theURL=1" | sed -n "/Link:/,/XSS/p" | awk -F'rel="next", ' '{print $2}' | sed -n 's/^.*&page=\(.*\)>;.*$/\1/p'`

echo "$org has $pages pages"

  for i in `seq 1 $pages`;
  do
    currURL="$theURL=$i"
    echo "Retrieving repos for $org from GitHub (page $i)"
    echo "curl -H \"Authorization: token $1\" $currURL"
    `curl -H "Authorization: token $1" $currURL >> $currentOrg`
  done
fi
echo -e "---------------exit $0---------------"





