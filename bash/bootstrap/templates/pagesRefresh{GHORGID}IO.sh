echo "########## refresh in $0 is set to $1"

{ROOT}/bash/driver/buildAndDeploy.sh {ROOT}/bash {ROOT}/output {EMAIL} {READKEY} {PUSHKEY} github.com/{GHORGID}/github-federal-stats.git $1
