echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 ) ]]; then
  echo "Usage: deployGHP.sh [outputDirectory] [user.email] [deployToken] [iopage]"
else
  outputDirectory=$1
  user=$2
  deployToken=$3
  iopage=$4
echo "root: $outputDirectory"
echo "user:$user"
echo "iopage:$iopage"
  rm -rf ghp
  cp -R $outputDirectory/publish/all/ ghp
  cd ghp 

  git init
  git config user.name "GH-PAGES-BUILD"
  git config user.email "$user"
  git add .
  git commit -m "Latest GH Pages"

  git push --force --quiet "https://$deployToken@$iopage" master:gh-pages > /dev/null 2>&1
fi
echo -e "\n---------------exit $0---------------"
