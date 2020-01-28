
#Docker for Boomi

#Prepare Docker boomi molecule image 

- Checkout the BoomiDocker ( git clone https://github.com/petabloc/BoomiDocker.git )
- Download the jdk installation from ( s3:///boomi-build-artifacts/jdk/8u181-b13/jdk-8u181-linux-x64.rpmx )
   extract the jdk folder using tar -zxv jdk-8u181-linux-x64.rpmx  jdk1.8.0_181
- ```docker build -t qa-mol . ```

Once you build docker image you can use it on local or push to ECR ``` (685785582420.dkr.ecr.us-west-2.amazonaws.com/qa-mol:latest)```


#Docker run 

	docker run -d qa-mol:letest
	Docker entrypoint will assing the env vriable and start the molecule.service

#SQS Setup

- Create fifo type sqs called dockerboomi.fifo
- addIdToSqs.py is to add the messages in queue messages('MOL_Qa_Node_1','MOL_Qa_Node_2','MOL_Qa_Node_3')
- getIdFromSqs.py is to read the messages form queue. getIdFromSqs.py run on container startup and get the messages from queue in fifo order and assing the message to evn variables ``` export ATOM_LOCALHOSTID="MOL_Qa_Node_1" ```


#Docker boomi molecule on ECS

- Create cluster called boomiDev
- Create lunch configration of autoscalling group with following user data

			Content-Type: multipart/mixed; boundary="==BOUNDARY=="
			MIME-Version: 1.0
			--==BOUNDARY==
			Content-Type: text/cloud-boothook; charset="us-ascii"
			# Mount /mnt/efs
			cloud-init-per instance add_efs_to_fstab echo -e 'fs-bf892e15:/ /mnt/efs efs defaults,_netdev 0 0' >> /etc/fstab
			# Mkdir /etc/ecs
			cloud-init-per instance mkdir_ecs mkdir /etc/ecs
			# write ecs.config
			cloud-init-per instance write_ecs_config echo -e "ECS_CLUSTER=BoomiDev" >> /etc/ecs/ecs.config
			--==BOUNDARY==
			Content-Type: text/x-shellscript; charset="us-ascii"
			#!/bin/bash
			yum update -y
			yum install -y amazon-efs-utils git
			amazon-linux-extras install -y ecs
			mkdir -p /mnt/efs
			if [[ ! $(mount | grep fs-bf892e15) ]]; then
			  mount -a
			fi
			# Start ecs service
			systemctl enable --now ecs &
			--==BOUNDARY==-- 

- Create task definition
- Volume definition

		"mountPoints": [
				{
				  "containerPath": "/mnt/data",
				  "sourceVolume": "efs-boomi"
				}
			  ],

		"volumes": [
			{
			  "host": {
				"sourcePath": "/mnt/efs"
			  },
			  "name": "efs-boomi"
			}
		  ],

- Run Task using ECS cluster

