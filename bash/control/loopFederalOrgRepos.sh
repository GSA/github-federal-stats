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
  #orgMatrix=$outputReportDirectory/orgMatrix.txt
  #orgXML=$outputReportDirectory/orgXML.xml
  orgHTML=$outputReportDirectory/index.html
  orgHTMLTemp=$outputTempDirectory/org.html.temp
  #orgHTML2=$outputReportDirectory/portable.html
  #descriptionHTMLPortable=$outputReportDirectory/descriptionPortable.html
  descriptionHTMLTemp=$outputTempDirectory/descriptionTemp.html

  echo > $federalRepos
  echo > $federalOrgInfo
  echo > $outputDataDirectory/pocs.txt
  echo > $outputDataDirectory/creationDates.txt 

  count=1
  echo "Preparing to loop through $ttlOrgs organizations"
#  echo -e "Organization\tType\tAgency\tSubagency\tSite\tAvatar\tBlog\tE-Mail\tRepositories\tMissing Project Descriptions\tInfo" > $orgMatrix
 # echo -e "<data>" > $orgXML

  cp -R $scriptsDirectory/html/CSS $outputReportDirectory
  cp -R $scriptsDirectory/html/Images $outputReportDirectory
  cp -R $scriptsDirectory/html/JS $outputReportDirectory
  cp -R $scriptsDirectory/html/datasheets $outputReportDirectory

  cp $scriptsDirectory/html/datatable.template $orgHTML
  echo > $orgHTMLTemp
  echo > $descriptionHTMLTemp
#  cat $scriptsDirectory/html/datatableportable.top > $orgHTML2
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
      $scriptsDirectory/retrieveData/pullFederalOrgRepos.sh $1 $org $outputSharedDataDirectory/orgs/"$org"FederalRepos.txt
    fi

    currentFederalRepos=$outputSharedDataDirectory/orgs/"$org"FederalRepos.txt

    $scriptsDirectory/parseData/getCurrentOrgReposConformance.sh $currentFederalRepos $configReader $configFile $token $org $outputDataDirectory $outputTempDirectory $scriptsDirectory $outputSharedDataDirectory

    #addInfo=`cat $outputDataDirectory/currentStats.txt`
    #addInfo2=`cat $outputDataDirectory/currentStatsXML.txt`
    addInfo3=`cat $outputDataDirectory/currentStatsHTML.txt`
    cat $currentFederalRepos >> $federalRepos

    #org2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed $org`
    url2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed $url`
    blog2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed $blog`
    email2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed $email`
    #bio2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed "$bio"`
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
    

   # echo -e "<org><name>$org2</name><type>$orgtype</type><agency>$agency</agency><subagency>$subagency2</subagency><url>$url2</url><avatar>$avatar</avatar><blog>$blog2</blog><email>$email2</email><repos>$repos</repos>$addInfo2<bio>$bio2</bio></org>" >> $orgXML

    echo -e "<tr><td headers='Logo'>$avatar2</td><td headers='Name'>$org3</td><td headers='Type'>$orgtype</td><td headers='Agency'>$agency</td><td headers='Sub_Agency'>$subagency</td><td headers='Blog'>$blog3</td><td headers='Email'>$email3</td><td headers='Repositories'>$repos</td>$addInfo3<td headers='Organizational_Info'>$bio3</td></tr>" >> $orgHTMLTemp
#    echo -e "<tr><td>$avatar2</td><td>$org3</td><td>$orgtype</td><td>$agency</td><td>$subagency2</td><td>$blog3</td><td>$email3</td><td>$repos</td>$addInfo3<td>$bio3</td></tr>" >> $orgHTML2

#    echo -e "$org\t$orgtype\t$agency\t$subagency\t$url\t$avatar\t$blog\t$email\t$repos\t$addInfo\t$bio" >> $orgMatrix

    count=$((count + 1))
  done < "$orgIndex"
  #echo -e "</data>" >> $orgXML

  echo "inserting organization data into web page template"
  $scriptsDirectory/parseData/insertDataIntoTemplate.sh $orgHTML $orgHTMLTemp "<!--TABLE1-->"

  echo "inserting repository data into web page template"
  #replace descriptionHTMLTemp in orgHTML
  $scriptsDirectory/parseData/insertDataIntoTemplate.sh $orgHTML $descriptionHTMLTemp "<!--TABLE2-->"
fi
echo -e "---------------exit $0---------------"

