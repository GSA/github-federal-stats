#echo "enter $0"

#configReader=$1
#configFile=$2
file=$1
repo=`echo $2 | awk -F'/' '{print $2}'`
field=$3

#echo $file

#outputDataDirectory=`$configReader $configFile outputDataDirectory`
#outputGHDirectory=`$configReader $configFile outputGHDirectory`
#outputReportDirectory=`$configReader $configFile outputReportDirectory`
#outputTempDirectory=`$configReader $configFile outputTempDirectory`
#scriptsDirectory=`$configReader $configFile scriptsDirectory`

#echo $field

sed -n "/\/$repo\",/,/\"score\":/p" $file | sed -n "/\"$field\"/p" | awk -F'"' '{print $4}'


#echo "exit $0"