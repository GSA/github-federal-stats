#determine commits/week.  If there have been none, then it could cause a division by zero error without the last if check
curl -s -H "Authorization: token $1" https://api.github.com/repos/$2/stats/participation | sed '1,/all/d;/\]/,$d' | sed 's/,$//' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | awk '{ total += $1; count++ } END { if (count > 0 ) print total/count; else print 0 }'

