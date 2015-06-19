if [[ ( -z $1 || -z $2 || -z $3 ) ]]; then 
  echo "Usage: getDataElement.sh [output directory] [org name] [element]"
elif [ ! -d "$1" ]; then
  echo "Directory does not exist!"
else
  file=$1$2OrgData.dat
  rv=`sed -ne "s/$3:.*/\0/p" $file | sed "s/$3://"`
  echo $rv
fi

