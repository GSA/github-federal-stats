echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 || -z $4 ) ]]; then
  echo "Usage: checkin.sh [user.name] [user.password] [file] [comment]"
else
  git config user.name "$1"
  git config user.password "$2"
  git add $3
  git commit -m "$4"
  git push origin master
fi
