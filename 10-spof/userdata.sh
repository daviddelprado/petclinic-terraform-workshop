#!/bin/bash

apt update
apt install jq awscli openjdk-17-jdk -y


mkdir  /app
aws s3 cp s3://demo-artifacts-20657/spring-petclinic-3.1.0-SNAPSHOT.jar /app/


FILE=$(ls /app/*.jar)

REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

MYSQL_ENDPOINT=$(aws ssm get-parameter \
  --with-decryption \
  --name "/__PREFIX__/__ENVIRONMENT__/databases/endpoint" \
  --query Parameter.Value \
  --output text \
  --region $REGION)
MYSQL_URL=jdbc:mysql://$MYSQL_ENDPOINT/petclinic
MYSQL_USER=admin
MYSQL_PASS=$(aws ssm get-parameter \
  --name "/__PREFIX__/__ENVIRONMENT__/databases/password/master" \
  --with-decryption \
  --query Parameter.Value \
  --output text \
  --region $REGION)

java \
  -Dspring.profiles.active=mysql \
  -Dserver.port=80 \
  -DMYSQL_USER=$MYSQL_USER \
  -DMYSQL_URL=$MYSQL_URL \
  -DMYSQL_PASS="$MYSQL_PASS" \
  -jar $FILE 
