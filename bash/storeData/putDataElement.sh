if [[ ( -z $1 || -z $2 || -z $3 || -z $4 ) ]]; then 
  echo "Usage: getDataElement.sh [output directory] [org name] [element] [value]"
elif [ ! -d "$1" ]; then
  echo "Directory does not exist!"
else
  file=$1$2OrgData.dat
  rv=`sed -i "s/$3:.*/$3:$4/" $file`
  echo $rv
fi

