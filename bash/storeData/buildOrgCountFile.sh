echo "enter $0"
if [[ ( -z $1  || -z $2 )]]; then 
  echo "Usage: buildOrgCountFile.sh [output directory] [org name]"
elif [ ! -d "$1" ]; then
  echo "Directory does not exist!"
else
  file=$1/$2OrgData.dat
  echo "organization:" >  $file
  echo "reposSite:" >> $file
  echo "website:" >> $file
  echo "email:" >> $file
  echo "description:" >> $file

  #counts
  echo "totalProjects:0" >> $file
  echo "missingProjectDescriptions:0" >>  $file
fi
echo "exit $0"
