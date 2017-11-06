local queue_name = KEYS[1]
local message_id = ARGV[1]
return redis.call('del', queue_name .. ':' .. message_id)