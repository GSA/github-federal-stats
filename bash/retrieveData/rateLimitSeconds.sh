curl -si -H "Authorization: token $1" https://api.github.com/rate_limit > ./limit.txt
limitup=`grep -m 1 reset ./limit.txt | awk '{print $2}'`
current=`date +%s`
diff=$((limitup-current))
rm ./limit.txt
echo "$diff"
