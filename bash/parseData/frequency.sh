  configReader=$1
  configFile=$2
  outputDataDirectory=`$configReader $configFile outputDataDirectory`
  outputGHDirectory=`$configReader $configFile outputGHDirectory`
  outputReportDirectory=`$configReader $configFile outputReportDirectory`
  outputTempDirectory=`$configReader $configFile outputTempDirectory`

#$3=source file
#$4=output directory
#$5=predicate name of output files
echo "calculating alphaFrequency$5.txt and placing file at $4/alphaFrequency$5.txt"
 sed 's/\.//g;s/\(.*\)/\L\1/;s/\ /\n/g' $3 | sort | uniq -c > $4/alphaFrequency$5.txt
echo "calculating frequency$5.txt and placing file at $4/frequency$5.txt"
 sed 's/\.//g;s/\(.*\)/\L\1/;s/\ /\n/g' $3 | sort | uniq -c | sort -rn > $4/frequency$5.txt
