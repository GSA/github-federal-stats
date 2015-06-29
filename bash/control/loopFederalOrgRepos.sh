echo -e "\n---------------enter $0---------------"
if [[ ( -z $1 || -z $2 || -z $3 ) ]]; then
  echo "Usage: loopFederalOrgRepos.sh [token] [configReader] [configFile] [optional:refresh(true|false)]"
else
  configReader=$2
  configFile=$3
  scriptsDirectory=`$configReader $configFile scriptsDirectory`
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  outputSharedDataDirectory=`$configReader $configFile outputSharedDataDirectory`
  outputGHDirectory=`$configReader $configFile outputGHDirectory`
  outputReportDirectory=`$configReader $configFile outputReportDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`
  mappingDirectory=$scriptsDirectory/mapping

  token=$1
  cat $outputDataDirectory/federalOrgs.txt 
  echo
  echo
  orgIndex=$outputDataDirectory/federalOrgs.txt

  if [[ ( -z $4 ) ]]; then
    refresh="true"
  else
    refresh=$4
  fi

  ttlOrgs=`grep -c ^ $orgIndex`
  ttlOrgs=$((ttlOrgs + 0))

  federalRepos=$outputGHDirectory/federalRepos.txt
  federalOrgInfo=$outputGHDirectory/federalOrgInfo.txt
  orgHTML=$outputReportDirectory/index.html
  orgHTMLTemp=$outputTempDirectory/org.html.temp
  descriptionHTMLTemp=$outputTempDirectory/descriptionTemp.html

  echo > $federalRepos
  echo > $federalOrgInfo
  echo > $outputDataDirectory/pocs.txt
  echo > $outputDataDirectory/creationDates.txt 
  echo > $outputDataDirectory/releases.txt

  count=1
  echo "Preparing to loop through $ttlOrgs organizations"

  cp -R $scriptsDirectory/html/CSS $outputReportDirectory
  cp -R $scriptsDirectory/html/jqplot $outputReportDirectory
  cp -R $scriptsDirectory/html/Images $outputReportDirectory
  cp -R $scriptsDirectory/html/JS $outputReportDirectory
  cp -R $scriptsDirectory/html/datasheets $outputReportDirectory

  cp $scriptsDirectory/html/datatable.template $orgHTML
  echo > $orgHTMLTemp
  echo > $descriptionHTMLTemp
  echo > $outputDataDirectory/projectDescriptions.txt
  echo > $outputDataDirectory/commitActivity.txt

  if [ ! -d "$outputSharedDataDirectory/orgs/" ]; then
    echo "making $outputSharedDataDirectory/orgs/ directory."
    mkdir -p $outputSharedDataDirectory/orgs/
  fi

  while read -r line
  do
    #get Org info
    name=$line
    org=`echo $name |  cut -d'/' -f 4`
    echo " "
    echo " "
    echo " "
    echo "Obtaining organization information for $org ($count/$ttlOrgs)"
   # echo "$((count%10))"
   # if  [[ $((count%10)) = 0 ]]; then
      echo "checking remaining queries..."
      remaining=`$scriptsDirectory/retrieveData/rateLimitRemaining.sh` 
      echo "$remaining remaining"
   # fi
    currentOrg=$outputSharedDataDirectory/orgs/$org.txt
    
    refresh=`$scriptsDirectory/retrieveData/checkRetrievalFlag.sh $configReader $configFile refreshGitHubOrgInfo $outputSharedDataDirectory/orgs/$org.txt`
    echo "refresh for $org info from GitHub =$refresh" 
    if [[ ( $refresh = "true" ) ]]; then
      $scriptsDirectory/retrieveData/pullFederalOrgInfo.sh $1 $org $outputSharedDataDirectory/orgs/$org.txt
    fi

#may be able to tighten this up to get all 3
    orgtype=`$scriptsDirectory/mapping/getType.sh $mappingDirectory/GHOrgAgency.txt $org`
    agency=`$scriptsDirectory/mapping/getAgency.sh $mappingDirectory/GHOrgAgency.txt $org`
    subagency=`$scriptsDirectory/mapping/getSubagency.sh $mappingDirectory/GHOrgAgency.txt $org`

#same here
    url=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg html_url`
    blog=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg blog`
    bio=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg bio`
    email=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg email`
    repos=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg public_repos`
    avatar=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg avatar_url`
    
    echo $email >> $outputDataDirectory/pocs.txt
    cat $currentOrg >> $federalOrgInfo

    #get Org repos
    echo "Obtaining repository information for $org"
  
    refresh=`$scriptsDirectory/retrieveData/checkRetrievalFlag.sh $configReader $configFile refreshGitHubReposInfo $outputSharedDataDirectory/orgs/"$org"FederalRepos.txt`
    if [[ ( $refresh = "true" ) ]]; then
      $scriptsDirectory/retrieveData/pullFederalOrgRepos.sh $token $org $outputSharedDataDirectory/orgs/"$org"FederalRepos.txt
    fi

    currentFederalRepos=$outputSharedDataDirectory/orgs/"$org"FederalRepos.txt

    $scriptsDirectory/parseData/getCurrentOrgReposConformance.sh $currentFederalRepos $configReader $configFile $token $org $outputDataDirectory $outputTempDirectory $scriptsDirectory $outputSharedDataDirectory

    addInfo3=`cat $outputDataDirectory/currentStatsHTML.txt`
    cat $currentFederalRepos >> $federalRepos

    url2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed $url`
    blog2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed $blog`
    email2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed $email`
    subagency2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed "$subagency"`
    avatar2="<img src=\"$avatar\" height=\"40\" width=\"40\">"

    org3="<a href=\"$url2\">$org</a>"
    if [ -z "$blog2" ]; then
      blog3="--"
    else
      blog3="<a href=\"$blog2\">$blog2</a>"
    fi

    if [ -z "$email2" ]; then
      email3="--"
    else
      email3=$email2
    fi

    if [ -z "$bio" ]; then
      bio3="--"
    else
      bio3=$bio
    fi
    
    echo -e "<tr><td headers='Logo'>$avatar2</td><td headers='Name'>$org3</td><td headers='Type'>$orgtype</td><td headers='Agency'>$agency</td><td headers='Sub_Agency'>$subagency</td><td headers='Blog'>$blog3</td><td headers='Email'>$email3</td><td headers='Repositories'>$repos</td>$addInfo3<td headers='Organizational_Info'>$bio3</td></tr>" >> $orgHTMLTemp

    count=$((count + 1))
  done < "$orgIndex"

  echo "inserting organization data into web page template"
  $scriptsDirectory/parseData/insertDataIntoTemplate.sh $orgHTML $orgHTMLTemp "<!--TABLE1-->"

  echo "inserting repository data into web page template"
  #replace descriptionHTMLTemp in orgHTML
  $scriptsDirectory/parseData/insertDataIntoTemplate.sh $orgHTML $descriptionHTMLTemp "<!--TABLE2-->"
fi
echo -e "---------------exit $0---------------"

