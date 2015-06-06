configReader=$1
configFile=$2
flagKey=$3
outputFile=$4

#scriptsDirectory=`$configReader $configFile scriptsDirectory`
#outputDataDirectory=`$configReader $configFile outputDataDirectory`
#outputGHDirectory=`$configReader $configFile outputGHDirectory`
#outputReportDirectory=`$configReader $configFile outputReportDirectory`
#outputTempDirectory=`$configReader $configFile outputTempDirectory`
#mappingDirectory=$scriptsDirectory/mapping

flag=`$configReader $configFile $flagKey`
#if flag is true, return true
if [[ ( $flag = "false" ) && -f $outputFile ]]; then
  echo "false"
else 
  echo "true"
fi


  