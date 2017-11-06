local queue_name = KEYS[1]
local payload = ARGV[1]

local message_id = redis.sha1hex(payload)

redis.call('rpush', queue_name, message_id)
redis.call('set', queue_name .. ':' .. message_id, payload)
return message_id
