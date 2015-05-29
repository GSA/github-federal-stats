echo "enter $0"

if [[ ( -z $1 || -z $2 || -z $3 ) ]]; then
  echo "Usage: buildGitHubIndex.sh [token] [configReader] [configFile] [optional:refresh (true|false)] [optional:federalOrgs]"
else

STARTTIME=$(date +%s)
echo "Script started: $(date)"
  if [[ ( -z $4 ) ]]; then
    refresh="true"
  else
    if [[ ! ( $4 = "true" || $4 = "false" ) ]]; then
      refresh="true"
      federalOrgs=$4
    else
      refresh=$4
    fi
  fi
  echo "Refresh set to $refresh"

  token=$1
  configReader=$2
  configFile=$3
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  outputGHDirectory=`$configReader $configFile outputGHDirectory`
  outputReportDirectory=`$configReader $configFile outputReportDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`
  scriptsDirectory=`$configReader $configFile scriptsDirectory`

  if [[ ( ! -z $5 ) ]]; then
    federalOrgs=$5

    #OK, an agency was passed in...
    if [[ ( ! $federalOrgs == *.txt ) ]]; then

      #OK, we want an agency level report...
      echo "creating a new config file from $configFile for $federalOrgs"
      #need to replace spaces with underscores
      federalOrgs="${federalOrgs// /_}"
      echo "agency:$federalOrgs" > $configFile.$federalOrgs
      echo "scriptsDirectory:$scriptsDirectory" >> $configFile.$federalOrgs
      echo "outputGHDirectory:$outputGHDirectory$federalOrgs" >> $configFile.$federalOrgs      
      echo "outputDataDirectory:$outputDataDirectory$federalOrgs" >> $configFile.$federalOrgs      
      echo "outputReportDirectory:$outputReportDirectory$federalOrgs" >> $configFile.$federalOrgs
      echo "outputTempDirectory:$outputTempDirectory$federalOrgs" >> $configFile.$federalOrgs      
      configFile=$configFile."$federalOrgs"

      #reset directories...
      outputDataDirectory=`$configReader $configFile outputDataDirectory`
      outputGHDirectory=`$configReader $configFile outputGHDirectory`
      outputReportDirectory=`$configReader $configFile outputReportDirectory`
      outputTempDirectory=`$configReader $configFile outputTempDirectory`
      scriptsDirectory=`$configReader $configFile scriptsDirectory`

      echo "new config file:$configFile"
    fi
  fi


  if [ ! -d "$outputDataDirectory" ]; then
    echo "making $outputDataDirectory directory."
    mkdir -p $outputDataDirectory
  fi
  if [ ! -d "$outputGHDirectory" ]; then
    echo "making $outputGHDirectory directory."
    mkdir -p $outputGHDirectory
  fi
  if [ ! -d "$outputReportDirectory" ]; then
    echo "making $outputReportDirectory directory."
    mkdir -p $outputReportDirectory
  fi
  if [ ! -d "$outputTempDirectory" ]; then
    echo "making $outputTempDirectory directory."
    mkdir -p $outputTempDirectory
  fi

  #see if an agency is denoted in the config file
  agency=`$configReader $configFile agency`  
  if [[ ( ! -z $agency ) ]]; then
    #need to search for agency using spaces
    tempAgency="${agency//_/ }"

    echo "agency is $tempAgency"
    `$scriptsDirectory/mapping/getOrgsforAgency.sh $scriptsDirectory/mapping/GHOrgAgency.txt "$tempAgency" > $outputTempDirectory/$agency.repos`
    
    #do check for subagency if name is a subagency...
    ttlOrgs=`cat $outputTempDirectory/$agency.repos | wc -l`
    ttlOrgs=$((ttlOrgs + 0))
    if [ $ttlOrgs -eq 0 ]; then
      echo "could not find agency...searching sub-agencies..."  
      `$scriptsDirectory/mapping/getOrgsforSubagency.sh $scriptsDirectory/mapping/GHOrgAgency.txt "$tempAgency" > $outputTempDirectory/$agency.repos`    
    fi
    federalOrgs=$outputTempDirectory/$agency.repos
  fi

  if [[ ( ! -z $federalOrgs ) ]]; then
    echo "output data directory=$outputDataDirectory"
    echo "federal orgs=$federalOrgs"
    `cp $federalOrgs $outputDataDirectory`
  fi  

  if [[ ( $refresh = "true" ) ]]; then
    if [[ ( -z $federalOrgs ) || ( $federalOrgs == *.repos ) ]]; then
      ./retrieveData/pullFederalOrgs.sh $token $configReader $configFile
    fi

    if [[ ( $federalOrgs == *.repos ) ]]; then
	cp $federalOrgs $outputDataDirectory/federalOrgs.txt
    fi
    ./control/loopFederalOrgRepos.sh $token $configReader $configFile
  else
    ./control/loopFederalOrgRepos.sh $token $configReader $configFile $refresh
  fi
  ./control/calculateTotals.sh $token $configReader $configFile
fi
echo "Script completed: $(date)"

ENDTIME=$(date +%s)
diff=$(($ENDTIME-$STARTTIME))
echo "Total elapsed time: $(($diff / 60))m $(($diff % 60))s"
echo "exit $0"