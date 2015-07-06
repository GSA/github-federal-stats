echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 ) ]]; then
  echo "Usage: bootstrap.sh [configFile]"
else
  configFile=$1
  ROOT=`sed -ne "s/ROOT:.*/\0/p" $configFile | sed "s/ROOT://"`
  configReader=$ROOT/bash/control/getConfigElement.sh

  echo "changing main script permissions to allow execution..."
  find $ROOT/bash/ -name "*.sh" -print -exec chmod 755 {} \;
  
  READKEY=`$configReader $configFile READKEY`
  PUSHKEY=`$configReader $configFile PUSHKEY`
  GHUSERID=`$configReader $configFile GHUSERID`
  GHORGID=`$configReader $configFile GHORGID`
  EMAIL=`$configReader $configFile EMAIL`
  WWWDIRECTORY=`$configReader $configFile WWWDIRECTORY`

  localScripts=$ROOT/localscripts
  echo "copying script templates to $localScripts"
  mkdir $localScripts
  cp $ROOT/bash/bootstrap/templates/* $localScripts

  echo "replacing ROOT values in script templates..."
  find $localScripts -type f -print0 | xargs -0 sed -i "s:{ROOT}:$ROOT:g"

  echo "replacing READKEY values in script templates..."
  find $localScripts -type f -print0 | xargs -0 sed -i "s:{READKEY}:$READKEY:g"

  echo "replacing PUSHKEY values in script templates..."
  find $localScripts -type f -print0 | xargs -0 sed -i "s:{PUSHKEY}:$PUSHKEY:g"

  echo "replacing GHUSERID values in script templates..."
  find $localScripts -type f -print0 | xargs -0 sed -i "s:{GHUSERID}:$GHUSERID:g"

  echo "replacing GHORGID values in script templates..."
  find $localScripts -type f -print0 | xargs -0 sed -i "s:{GHORGID}:$GHORGID:g"

  echo "replacing EMAIL values in script templates..."
  find $localScripts -type f -print0 | xargs -0 sed -i "s:{EMAIL}:$EMAIL:g"

  echo "replacing WWWDIRECTORY values in script templates..."
  find $localScripts -type f -print0 | xargs -0 sed -i "s:{WWWDIRECTORY}:$WWWDIRECTORY:g"
  
  echo "replacing localscripts values in script templates..."
  find $localScripts -type f -print0 | xargs -0 sed -i "s:{LOCALSCRIPTS}:$localScripts:g"

  echo "updating .bashrc..."
  echo "##### start of aliases added by bootstrap script #####" >> ~/.bashrc
  cat $localScripts/bashrc.snippet >> ~/.bashrc
  echo "##### end of aliases added by bootstrap script #####" >> ~/.bashrc
  source ~/.bashrc
  rm $localScripts/bashrc.snippet

  echo "renaming script files..."
  theFile="$localScripts/pushLocalTo{GHORGID}IO.sh"
  `mv $theFile ${theFile//\{GHORGID\}/$GHORGID}`
  theFile="$localScripts/pagesRefresh{GHORGID}IO.sh"
  `mv $theFile ${theFile//\{GHORGID\}/$GHORGID}`

  echo "changing local script permissions to allow execution..."
  find $localScripts -name "*.sh" -print -exec chmod 755 {} \;
fi

echo -e "\n---------------exit $0---------------"
