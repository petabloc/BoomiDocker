#!/bin/bash

#Exeute the get sqs message python script 
nodeName=$(python getIdFromSqs.py 2>&1 )
echo "$nodeName"
#set the env vriable name in container startup
echo "export ATOM_LOCALHOSTID=$nodeName" >> ~/.bash_profile && source ~/.bash_profile
touch /etc/profile.d/boomi.sh && echo "export ATOM_LOCALHOSTID=$nodeName" >> /etc/profile.d/boomi.sh 

#sleep 1000
systemctl enable mol_qa.service
