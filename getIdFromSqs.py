#!/usr/bin/python
import boto3
import subprocess
import time
# Get the service resource
sqs = boto3.resource('sqs',region_name='us-west-2')
# Get the queue
queue = sqs.get_queue_by_name(QueueName='dockerboomi.fifo')
# Process messages by printing out body
for message in queue.receive_messages(VisibilityTimeout=3600,WaitTimeSeconds=20):
	# Print out the body of the message
	print('{0}'.format(message.body))
	# Let the queue know that the message is processed
	message.delete()
