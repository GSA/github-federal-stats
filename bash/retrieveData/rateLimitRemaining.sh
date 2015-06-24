curl -si -H "Authorization: token $1" https://api.github.com/rate_limit > ./limit.txt
limitup=`grep -m 1 remaining ./limit.txt | awk '{print $2}' | awk -F"," '{print $1}'` 
rm ./limit.txt
echo "$limitup"
