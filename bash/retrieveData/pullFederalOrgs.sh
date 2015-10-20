echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 ) ]]; then
  echo "Usage: pullFederalOrgs.sh [token] [configReader] [configFile]"
else
  configReader=$2
  configFile=$3
  scriptsDirectory=`$configReader $configFile scriptsDirectory`
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
#  outputGHDirectory=`$configReader $configFile outputGHDirectory`
#  outputReportDirectory=`$configReader $configFile outputReportDirectory`
#  outputTempDirectory=`$configReader $configFile outputTempDirectory`

  refresh=`$scriptsDirectory/retrieveData/checkRetrievalFlag.sh $configReader $configFile refreshUSFederalList $outputDataDirectory/federalOrgsRaw.txt`
  echo "refresh for federal organizations using GitHub=$refresh" 
  if [[ ( $refresh = "true" ) ]]; then
    echo "Retrieving federal organizations using GitHub"
    curl -H "Authorization: token $1" "https://government.github.com/community/" > $outputDataDirectory/federalOrgsRaw.txt 
  fi

  sed -ne 's/.*\(https[^"]*\).*/\1/p' $outputDataDirectory/federalOrgsRaw.txt | sed -n -e '/18f/,$p' | sed '/whitehouse/q' > $outputDataDirectory/federalOrgs.txt 
  sed -ne 's/.*\(https[^"]*\).*/\1/p' $outputDataDirectory/federalOrgsRaw.txt | sed -n -e '/afseo/,$p' | sed '/usarmyresearchlab/q' >> $outputDataDirectory/federalOrgs.txt 
  sed -ne 's/.*\(https[^"]*\).*/\1/p' $outputDataDirectory/federalOrgsRaw.txt | sed -n -e '/ACME-Climate/,$p' | sed '/zfsonlinux/q' >> $outputDataDirectory/federalOrgs.txt 
  #following is for testing the scripts - it stops after articlcc.org repo
  #sed -ne 's/.*\(https[^"]*\).*/\1/p' $outputDataDirectory/federalOrgsRaw.txt | sed -n -e '/18f/,$p' | sed '/arcticlcc/q' > $outputDataDirectory/federalOrgs.txt 
  sed -ni '/png/!p' $outputDataDirectory/federalOrgs.txt 
  sed -i '/^https:\/\/avatars/d' $outputDataDirectory/federalOrgs.txt 
  sed -i '$!N; /^\(.*\)\n\1$/!P; D' $outputDataDirectory/federalOrgs.txt 
fi
echo -e "---------------exit $0---------------"
