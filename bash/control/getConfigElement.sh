if [[ ( -z $1 || -z $2 ) ]]; then 
  echo "Usage: getConfigElement.sh [configFile] [element]"
else
  file=$1
  rv=`sed -ne "s/$2:.*/\0/p" $file | sed "s/$2://"`
  echo $rv
fi

