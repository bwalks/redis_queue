# redis_queue
Redis LISTs can be easily used as a FIFO queue, but they lack the ability to reprocess messages that fail. Clients have to re-add failed messages to the queue so they could be reprocessed. 

These Lua scripts support this in Redis. Each queue will have a corresponding `queue_name:inflight` LIST that contains all of the in-flight messages. Any time a message is retrieved by a client, it is moved to that queue and is marked with a timeout that prevents other clients from reading that message until the timeout is complete or the message is marked as processed.
