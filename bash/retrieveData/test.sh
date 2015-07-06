
  theURL="https://api.github.com/search/repositories?q=user:GSA&per_page=100&page"

  echo "checking the number of pages for repos API call"
  pages=`curl -Is "$theURL=1" | sed -n "/Link:/,/XSS/p" | awk -F'rel="next", ' '{print $2}' | sed -n 's/^.*&page=\(.*\)>;.*$/\1/p'`

echo "gsa has $pages pages"






