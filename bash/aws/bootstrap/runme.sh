latestVersion=0.87
sudo yum update
sudo yum install git
mkdir /home/ec2-user/github
cd /home/ec2-user/github
curl https://codeload.github.com/GSA/github-federal-stats/tar.gz/v$latestVersion | tar xvz && mv github-federal-stats-$latestVersion github-federal-stats
mkdir /home/ec2-user/github/github-federal-stats/output

/home/ec2-user/github/github-federal-stats/bash/aws/bootstrap/setEST.sh
/home/ec2-user/github/github-federal-stats/bash/aws/bootstrap/createWebServer.sh

echo -n "Enter your GitHub user id and press [ENTER]: "
read ghUserId
echo -n "Enter your email address and press [ENTER]: "
read email
echo -n "Enter your GitHub org id and press [ENTER]: "
read ghOrgId
echo -n "Enter your GitHub key to read and press [ENTER]: "
read readKey
echo -n "Enter your GitHub key to push and press [ENTER]: "
read pushKey
echo "creating bootstrap.config file at /home/ec2-user/bootstrap.config"

echo "ROOT:/home/ec2-user/github/github-federal-stats" > /home/ec2-user/bootstrap.config
echo "READKEY:$readKey" >> /home/ec2-user/bootstrap.config
echo "PUSHKEY:$pushKey" >> /home/ec2-user/bootstrap.config
echo "GHUSERID:$ghUserId" >> /home/ec2-user/bootstrap.config
echo "GHORGID:$ghOrgId" >> /home/ec2-user/bootstrap.config
echo "EMAIL:$email" >> /home/ec2-user/bootstrap.config
echo "WWWDIRECTORY:/var/www/html" >> /home/ec2-user/bootstrap.config

/home/ec2-user/github/github-federal-stats/bash/bootstrap/bootstrap.sh ~/bootstrap.config

