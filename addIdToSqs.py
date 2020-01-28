#!/usr/bin/python
import boto3
import datetime
import time
# Get the service resource
sqs = boto3.resource('sqs',region_name='us-west-2')
# Get the queue
queue = sqs.get_queue_by_name(QueueName='dockerboomi.fifo')
data = ['MOL_Qa_Node_1','MOL_Qa_Node_2','MOL_Qa_Node_3']
for x in data:
	print x
	ts = time.time()
	time.sleep(1) # Delay for 1 seconds
	response = queue.send_message(
	    MessageBody=x,
	    MessageGroupId='MolNodeQa',
	    MessageDeduplicationId=str(ts)
	)
