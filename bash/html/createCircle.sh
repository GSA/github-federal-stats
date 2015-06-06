echo -e "\n---------------enter $0---------------"
cp $1 $2
sed -i "s/CIRCLE_NAME/$3/g" $2
sed -i "s/CIRCLE_TEXT/$4/g" $2
sed -i "s/CIRCLE_VALUE/$5/g" $2
echo -e "---------------exit $0---------------"
