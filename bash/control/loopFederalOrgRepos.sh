echo "enter $0"
if [[ ( -z $1 || -z $2 || -z $3 ) ]]; then
  echo "Usage: loopFederalOrgRepos.sh [token] [configReader] [configFile] [optional:refresh(true|false)]"
else
  configReader=$2
  configFile=$3
  scriptsDirectory=`$configReader $configFile scriptsDirectory`
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
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

  ttlOrgs=`cat $orgIndex | wc -l`
  ttlOrgs=$((ttlOrgs + 0))

  federalRepos=$outputGHDirectory/federalRepos.txt
  federalOrgInfo=$outputGHDirectory/federalOrgInfo.txt
  orgMatrix=$outputReportDirectory/orgMatrix.txt
  orgXML=$outputReportDirectory/orgXML.xml
  orgHTML=$outputReportDirectory/index.html
  orgHTMLTemp=$outputTempDirectory/org.html.temp
  orgHTML2=$outputReportDirectory/portable.html
  descriptionHTMLPortable=$outputReportDirectory/descriptionPortable.html
  descriptionHTMLTemp=$outputTempDirectory/descriptionTemp.html

  echo > $federalRepos
  echo > $federalOrgInfo
  echo > $outputDataDirectory/pocs.txt
  echo > $outputDataDirectory/creationDates.txt 

  count=1
  echo "Preparing to loop through $ttlOrgs organizations"
  echo -e "Organization\tType\tAgency\tSubagency\tSite\tAvatar\tBlog\tE-Mail\tRepositories\tMissing Project Descriptions\tInfo" > $orgMatrix
  echo -e "<data>" > $orgXML
  #cp -R $scriptsDirectory/html/DataTables-1.10.7 $outputReportDirectory
  cp $scriptsDirectory/html/*.docx $outputReportDirectory
#  cat $scriptsDirectory/html/datatable.top > $orgHTML
  cat $scriptsDirectory/html/datatable.template > $orgHTML
  echo > $orgHTMLTemp
  echo > $descriptionHTMLTemp
  cat $scriptsDirectory/html/descriptionHTML.top > $descriptionHTMLPortable
  cat $scriptsDirectory/html/datatableportable.top > $orgHTML2
  echo > $outputDataDirectory/projectDescriptions.txt
  echo > $outputDataDirectory/commitActivity.txt

  if [ ! -d "$outputDataDirectory/orgs/" ]; then
    echo "making $outputDataDirectory/orgs/ directory."
    mkdir -p $outputDataDirectory/orgs/
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
    currentOrg=$outputDataDirectory/orgs/$org.txt
    
    echo "refresh=$refresh"
    if [[ ( $refresh = "true" ) || ( ! -f $currentOrg ) ]]; then
      $scriptsDirectory/retrieveData/pullFederalOrgInfo.sh $1 $org > $currentOrg
    fi

    orgtype=`$scriptsDirectory/mapping/getType.sh $mappingDirectory/GHOrgAgency.txt $org`
    agency=`$scriptsDirectory/mapping/getAgency.sh $mappingDirectory/GHOrgAgency.txt $org`
    subagency=`$scriptsDirectory/mapping/getSubagency.sh $mappingDirectory/GHOrgAgency.txt $org`

    url=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg html_url`
    blog=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg blog`
    bio=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg bio`
    email=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg email`
    repos=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg public_repos`
    avatar=`$scriptsDirectory/parseData/getOrgField.sh $currentOrg avatar_url`
    
    echo $email >> $outputDataDirectory/pocs.txt
    cat $currentOrg >> $federalOrgInfo

    #get Org repos
    currentFederalRepos=$outputDataDirectory/orgs/"$org"FederalRepos.txt

    echo "Obtaining repository information for $org"
    if [[ ( $refresh = "true" )  || ( ! -f $currentFederalRepos ) ]]; then
      $scriptsDirectory/retrieveData/pullFederalOrgRepos.sh $1 $org > $currentFederalRepos 
    fi

    $scriptsDirectory/parseData/getCurrentOrgReposConformance.sh $currentFederalRepos $configReader $configFile $token $org

    addInfo=`cat $outputDataDirectory/currentStats.txt`
    addInfo2=`cat $outputDataDirectory/currentStatsXML.txt`
    addInfo3=`cat $outputDataDirectory/currentStatsHTML.txt`
    cat $currentFederalRepos >> $federalRepos

    org2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed $org`
    url2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed $url`
    blog2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed $blog`
    email2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed $email`
    bio2=`$scriptsDirectory/parseData/urlEncode.sh $scriptsDirectory/parseData/xmlencode.sed "$bio"`
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

    if [ -z "$bio2" ]; then
      bio3="--"
    else
      bio3=$bio2
    fi
    

    echo -e "<org><name>$org2</name><type>$orgtype</type><agency>$agency</agency><subagency>$subagency2</subagency><url>$url2</url><avatar>$avatar</avatar><blog>$blog2</blog><email>$email2</email><repos>$repos</repos>$addInfo2<bio>$bio2</bio></org>" >> $orgXML

    echo -e "<tr><td>$avatar2</td><td>$org3</td><td>$orgtype</td><td>$agency</td><td>$subagency2</td><td>$blog3</td><td>$email3</td><td>$repos</td>$addInfo3<td>$bio3</td></tr>" >> $orgHTMLTemp
    echo -e "<tr><td>$avatar2</td><td>$org3</td><td>$orgtype</td><td>$agency</td><td>$subagency2</td><td>$blog3</td><td>$email3</td><td>$repos</td>$addInfo3<td>$bio3</td></tr>" >> $orgHTML2

    echo -e "$org\t$orgtype\t$agency\t$subagency\t$url\t$avatar\t$blog\t$email\t$repos\t$addInfo\t$bio" >> $orgMatrix

    count=$((count + 1))
  done < "$orgIndex"
  echo -e "</data>" >> $orgXML

#  cat $scriptsDirectory/html/datatable.bottom >> $orgHTML
  echo $orgHTMLTemp
  echo $orgHTML
  echo $descriptionHTMLTemp
  #replace orgHTMLTemp in orgHTML
  FILE2=$(<"$orgHTML")
  FILE1=$(<"$orgHTMLTemp")
  echo "${FILE2//<!--TABLE1-->/$FILE1}" > $orgHTML

  #replace descriptionHTMLTemp in orgHTML
  FILE2=$(<"$orgHTML")
  FILE1=$(<"$descriptionHTMLTemp")
  echo "${FILE2//<!--TABLE2-->/$FILE1}" > $orgHTML

  cat $scriptsDirectory/html/datatableportable.bottom >> $orgHTML2
  cat $scriptsDirectory/html/descriptionHTML.bottom >> $descriptionHTMLPortable
fi
echo "exit $0"

