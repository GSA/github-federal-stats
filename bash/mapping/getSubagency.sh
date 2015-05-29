grep "$2:" < $1 | awk -F: '{ print $4 }'
