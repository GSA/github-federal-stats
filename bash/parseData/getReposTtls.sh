
  configReader=$1
  configFile=$2
  outputGHDirectory=`$configReader $configFile outputGHDirectory`
#  outputReportDirectory=`$configReader $configFile outputReportDirectory`
#  outputTempDirectory=`$configReader $configFile outputTempDirectory`
#  outputDataDirectory=`$configReader $configFile outputDataDirectory`

searchString=$3
outputFile=$4

federalRepos=$outputGHDirectory/federalRepos.txt

sed -ne "s/.*\"$searchString\":.*/\0/p" $federalRepos | sed "s/\""$searchString"\"://" | sed 's/.$//' | sed 's/"\(.*\)"$/\1/' > $outputFile
sed "s/^[ \t]*//" -i $outputFile

ttlProjects=`grep -c ^ $outputFile`
ttlProjects=$((ttlProjects+0)) 
echo "$ttlProjects"

