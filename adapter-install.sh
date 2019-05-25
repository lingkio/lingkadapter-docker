#!/bin/bash
# Installation script for lingk adapter
# Asks for 2 inputs
# 1: path of lingksync file
# 2: path of lingk ldap file

# How to run
# chmod 755 adapter-install.sh
# ./adapter-install.sh 

# Logs are available here
# lingkadapter-install.log

LOG_FILE=lingkadapter-install.log

# General Error Function
error() {
  printf '\E[31m'; echo "$@"; printf '\E[0m'
  echo "$@" >> $LOG_FILE
}

# Run as root, of course
#if [ "$(id -u)" != "0" ] 
#then
#    error "This script should be run using sudo or as the root user"
#    exit 1
#else
   echo "root verified"
#fi

echo "Installation started " `date -u` > $LOG_FILE
echo "checking docker installation..." | tee -a $LOG_FILE
which docker
if [ $? -eq 0 ]
then
    docker --version | grep "Docker version" | tee -a $LOG_FILE
    if [ $? -eq 0 ]
    then
        echo "docker exists" | tee -a $LOG_FILE
    else
        error "ERROR: docker not found. Please install docker and retry"
    fi
else
    error "ERROR: docker not found. Please install docker and retry"
fi

echo "checking docker-compose installation..." | tee -a $LOG_FILE
which docker-compose

if [ $? -eq 0 ]
then
    docker-compose --version | grep "docker-compose version" | tee -a $LOG_FILE
    if [ $? -eq 0 ]
    then
        echo "docker-compose exists" | tee -a $LOG_FILE
    else
        error "ERROR: docker-compose not found. Please install docker and retry"
    fi
else
    error "ERROR: docker-compose not found. Please install docker-compose and retry"
fi

ADAPTER_FILE="lingksync.tar.gz"
LDAP_FILE="lingkldap.tar.gz"
DOCKER_FILE="docker-compose.yml"

echo "Enter path of Lingksync adapter file" | tee -a $LOG_FILE
read adapter 
echo "Entered file path: "$adapter >> $LOG_FILE
echo "Enter path of Lingk ldap file" | tee -a $LOG_FILE
read ldap
echo "Entered file path: "$ldap >> $LOG_FILE

# docker-compose can either be read from remote location or one that is downloaded as part of repository can be used
# option1: download from remote location
#echo "Enter location of the docker-compose file" | tee -a $LOG_FILE
#read dockfile 
#echo "Entered file path: "$dockfile >> $LOG_FILE
# option2: use the one downloaded with repository
dockerfile="docker-compose.yml"

mkdir ./downloaded

echo "downloading "$ADAPTER_FILE " from "$adapter"..." | tee -a $LOG_FILE
wget -O ./downloaded/$ADAPTER_FILE $adapter 2>> $LOG_FILE
echo "downloading "$LDAP_FILE " from "$ldap"..." | tee -a $LOG_FILE
wget -O ./downloaded/$LDAP_FILE $ldap 2>> $LOG_FILE 
# Uncomment below lines if option1 is used i.e. docker-file downloaded from remote location
#echo "downloading "$DOCKER_FILE" from "$dockfile"..." | tee -a $LOG_FILE
#wget -O ./downloaded/$DOCKER_FILE $dockfile 2>> $LOG_FILE

echo "loading as docker image:"$adapter | tee -a $LOG_FILE
docker load < ./downloaded/$ADAPTER_FILE 2>> $LOG_FILE

echo "loading as docker image:"$ldap | tee -a $LOG_FILE
docker load < ./downloaded/$LDAP_FILE 2>> $LOG_FILE

echo "installing docker containers from loaded images using "$dockerfile"..." | tee -a $LOG_FILE
`docker-compose -f $DOCKER_FILE up -d` 2>> $LOG_FILE

echo "Installation ended " `date -u` >> $LOG_FILE
echo "Installation ended - check log file for details " $LOG_FILE
exit 0
