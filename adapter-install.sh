#!/bin/bash
# Installation script for lingk adapter
# Asks for 3 inputs
# 1: path of lingksync file
# 2: path of lingk ldap file
# 3: path of docker-compose.yml

# How to run
# chmod 755 adapter-install.sh
# ./adapter-install.sh 

# Logs are available here
# lingkadapter-install.log

# Run as root, of course.

LOG_FILE=lingkadapter-install.log

echo "Installation started " `date -u` > $LOG_FILE
which docker

if [ $? -eq 0 ]
then
    docker --version | grep "Docker version" | tee -a $LOG_FILE
    if [ $? -eq 0 ]
    then
        echo "docker exists" | tee -a $LOG_FILE
    else
        echo "install docker" | tee -a $LOG_FILE
    fi
else
    echo "ERROR: docker not found. Please install docker and retry" | tee -a $LOG_FILE
    exit 1
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
#echo "Enter location of the docker-compose file" | tee -a $LOG_FILE
#read dockfile 
#echo "Entered file path: "$dockfile >> $LOG_FILE

# Above can be uncommented to take input from the user itself for dockerfile
dockerfile="docker-compose.yml"

mkdir ./downloaded

echo "downloading "$ADAPTER_FILE " from "$adapter"..." | tee -a $LOG_FILE
wget -O ./downloaded/$ADAPTER_FILE $adapter 2>> $LOG_FILE
echo "downloading "$LDAP_FILE " from "$ldap"..." | tee -a $LOG_FILE
wget -O ./downloaded/$LDAP_FILE $ldap 2>> $LOG_FILE 
echo "downloading "$DOCKER_FILE" from "$dockfile"..." | tee -a $LOG_FILE
wget -O ./downloaded/$DOCKER_FILE $dockfile 2>> $LOG_FILE

echo "loading as docker image:"$adapter | tee -a $LOG_FILE
docker load < ./downloaded/$ADAPTER_FILE 2>> $LOG_FILE

echo "loading as docker image:"$ldap | tee -a $LOG_FILE
docker load < ./downloaded/$LDAP_FILE 2>> $LOG_FILE

echo "installing docker containers from loaded images..."$dockfile | tee -a $LOG_FILE
`docker-compose -f $DOCKER_FILE up -d` 2>> $LOG_FILE

echo "Installation ended " `date -u` >> $LOG_FILE
echo "Installation ended - check log file for details " $LOG_FILE
exit 0

