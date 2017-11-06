#!/usr/bin/python

import time

import redis


def register(filename, client):
  with open(filename, 'r') as f:
    return client.register_script(f.read())


queue = 'myqueue'
client = redis.StrictRedis(host='localhost', port=7200)
initialize = register('initialize_queue.lua', client)
insert = register('insertion.lua', client)
get = register('get_message.lua', client)
ack = register('acknowledge.lua', client)

# Initializing myqueue to have a TTL of 10 seconds for in-flight messages
initialize(keys=[queue], args=[10])

# message_id is returned to allow deletion of messages that have not been processed
message_id = insert(keys=[queue], args=['payload'])

# Message is now in the myqueue:in-flight queue
message_id, payload = get(keys=[queue])
print "Received %s: %s" % (message_id, payload)

# Acknowledge message as processed
ack(keys=[queue], args=[message_id])
