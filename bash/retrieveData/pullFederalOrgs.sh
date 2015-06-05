echo "enter $0"
if [[ ( -z $1 || -z $2 ) ]]; then
  echo "Usage: pullFederalOrgs.sh [token] [configReader] [configFile]"
else
  configReader=$2
  configFile=$3
  scriptsDirectory=`$configReader $configFile scriptsDirectory`
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  outputGHDirectory=`$configReader $configFile outputGHDirectory`
  outputReportDirectory=`$configReader $configFile outputReportDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`

  echo "Retrieving federal organizations using GitHub"
  curl -H "Authorization: token $1" https://government.github.com/community/ > $outputTempDirectory/federalOrgsRaw.txt 
  sed -ne 's/.*\(https[^"]*\).*/\1/p' $outputTempDirectory/federalOrgsRaw.txt | sed -n -e '/18f/,$p' | sed '/whitehouse/q' > $outputDataDirectory/federalOrgs.txt 
  #following is for testing the scripts - it stops after articlcc.org repo
  #sed -ne 's/.*\(https[^"]*\).*/\1/p' $outputTempDirectory/federalOrgsRaw.txt | sed -n -e '/18f/,$p' | sed '/arcticlcc/q' > $outputDataDirectory/federalOrgs.txt 
  sed -ni '/png/!p' $outputDataDirectory/federalOrgs.txt 
  sed -i '$!N; /^\(.*\)\n\1$/!P; D' $outputDataDirectory/federalOrgs.txt 
fi
echo "exit $0"
