echo -e "\n---------------enter $0---------------"
export LC_ALL=C

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
  outputSharedDataDirectory=`$configReader $configFile outputSharedDataDirectory`
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
#      echo "agency:$federalOrgs" > $configFile.$federalOrgs
#      echo "scriptsDirectory:$scriptsDirectory" >> $configFile.$federalOrgs
#      echo "outputGHDirectory:$outputGHDirectory$federalOrgs" >> $configFile.$federalOrgs      
#      echo "outputDataDirectory:$outputDataDirectory$federalOrgs" >> $configFile.$federalOrgs      
#      echo "outputReportDirectory:$outputReportDirectory$federalOrgs" >> $configFile.$federalOrgs
#      echo "outputTempDirectory:$outputTempDirectory$federalOrgs" >> $configFile.$federalOrgs 

      echo -e "agency:$federalOrgs\nscriptsDirectory:$scriptsDirectory\noutputGHDirectory:$outputGHDirectory/$federalOrgs\noutputDataDirectory:$outputDataDirectory/$federalOrgs\noutputSharedDataDirectory:$outputSharedDataDirectory\noutputReportDirectory:$outputReportDirectory/$federalOrgs\noutputTempDirectory:$outputTempDirectory/$federalOrgs" > $configFile.$federalOrgs 

#  outputSharedDataDirectory=`$configReader $configFile outputSharedDataDirectory`
#      flag1=`$configReader $configFile refreshUSFederalList`     
#     echo "refreshUSFederalList:$flag1" >> $configFile.$federalOrgs 

#      flag2=`$configReader $configFile refreshGitHubOrgInfo`     
#      echo "refreshGitHubOrgInfo:$flag2" >> $configFile.$federalOrgs 

#      flag3=`$configReader $configFile refreshGitHubReposInfo`     
#      echo "refreshGitHubReposInfo:$flag3" >> $configFile.$federalOrgs 

#      flag4=`$configReader $configFile refreshGitHubCommitsInfo`     
#      echo "refreshGitHubCommitsInfo:$flag4" >> $configFile.$federalOrgs 

#      flag5=`$configReader $configFile refreshOrgsForAgency`     
#      echo "refreshOrgsForAgency:$flag5" >> $configFile.$federalOrgs 


      flag1=`$configReader $configFile refreshUSFederalList`     
      flag2=`$configReader $configFile refreshGitHubOrgInfo`     
      flag3=`$configReader $configFile refreshGitHubReposInfo`     
      flag4=`$configReader $configFile refreshGitHubCommitsInfo`     
      flag5=`$configReader $configFile refreshOrgsForAgency`     

      echo -e "refreshUSFederalList:$flag1\nrefreshGitHubOrgInfo:$flag2\nrefreshGitHubReposInfo:$flag3\nrefreshGitHubCommitsInfo:$flag4\nrefreshOrgsForAgency:$flag5" >> $configFile.$federalOrgs

 
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

  refresh=`$scriptsDirectory/retrieveData/checkRetrievalFlag.sh $configReader $configFile refreshOrgsForAgency $outputDataDirectory/$agency.repos`

  echo "refresh orgs for agency $tempAgency = $refresh" 

  if [[ ( $refresh = "true" ) ]]; then
    echo "calling getOrgsforAgency.sh for $tempAgency "
    $scriptsDirectory/mapping/getOrgsforAgency.sh $scriptsDirectory/mapping/GHOrgAgency.txt "$tempAgency" > $outputDataDirectory/$agency.repos
  fi


    
    #do check for subagency if name is a subagency...
    #no need to check refresh because it would be there if there were none and data was already retrieved
    ttlOrgs=`cat $outputDataDirectory/$agency.repos | wc -l`
    ttlOrgs=$((ttlOrgs + 0))
    if [ $ttlOrgs -eq 0 ]; then
      echo "could not find agency...searching sub-agencies..." 
      echo "calling getOrgsforSubagency.sh"
      $scriptsDirectory/mapping/getOrgsforSubagency.sh $scriptsDirectory/mapping/GHOrgAgency.txt "$tempAgency" > $outputDataDirectory/$agency.repos
    fi
    federalOrgs=$outputDataDirectory/$agency.repos
  fi

 # if [[ ( ! -z $federalOrgs ) ]]; then
  #  echo "output data directory=$outputDataDirectory"
   # echo "federal orgs=$federalOrgs"
   # `cp $federalOrgs $outputDataDirectory`
  #fi  

  if [[ ( $refresh = "true" ) ]]; then
    if [[ ( -z $federalOrgs ) || ( $federalOrgs == *.repos ) ]]; then
      $scriptsDirectory/retrieveData/pullFederalOrgs.sh $token $configReader $configFile
    fi

    if [[ ( $federalOrgs == *.repos ) ]]; then
	cp $federalOrgs $outputDataDirectory/federalOrgs.txt
    fi
    $scriptsDirectory/control/loopFederalOrgRepos.sh $token $configReader $configFile
  else
    $scriptsDirectory/control/loopFederalOrgRepos.sh $token $configReader $configFile $refresh
  fi
  $scriptsDirectory/control/calculateTotals.sh $token $configReader $configFile
fi
rm limit.txt
echo "Script completed: $(date)"

ENDTIME=$(date +%s)
diff=$(($ENDTIME-$STARTTIME))
echo "Total elapsed time: $(($diff / 60))m $(($diff % 60))s"
echo -e "---------------exit $0---------------"
