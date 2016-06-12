#/bin/bash
# Inspired by https://hub.jazz.net/project/communitysample/postgresql-nodejs/overview
# You need CF CLI before running this script: https://console.ng.bluemix.net/docs/cli/index.html#cli
# Sample of argument
# amqps://user:edu0range@aws-us-east-1-portal.15.dblayer.com:10879/excellent-rabbitmq-78

APP_NAME=patrocinio-test-rabbitmq

if [ ! -z $1 ]
then
  URL=$1
else
  echo "Usage test-rabbit.sh <RabbitMQ-URL>"
 echo Sample: test-rabbit.sh amqps://user:edu0range@aws-us-east-1-portal.15.dblayer.com:10879/excellent-rabbitmq-78
  exit 1
fi

# Parameters
# $1: app name
# $2: name
check_url () {
# Grab URL
URL=`cf app $APP_NAME | grep urls | awk '{print $2}' | cut -f1 -d','`

# Check response
LINE=`wget --server-response --content-on-error=off ${URL} 2>&1 | grep HTTP`

# Prints result
if [[ "$LINE" == *"200"* ]]; then
echo $2 working great!
else
echo $2 failed :-/
fi
}

# Bind the app to the service
SERVICE_NAME=rabbitmq-test
cf uups $SERVICE_NAME -p '{"url":"'$URL'"}'

# Push the application
cf push $APP_NAME --random-route

# Check response
check_url $APP_NAME "RabbitMQ"
