while read -r line
do
  agency=$(echo $line | awk -F: '{print $3}')
  if [ "$agency" == "$2" ]; then
    repo=$(echo $line | awk -F: '{print $1}')
    echo "https://github.com/$repo"
  fi
done < $1
