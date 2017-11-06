local queue_name = KEYS[1]
local ttl = ARGV[1]

redis.call('set', queue_name .. ':ttl', ttl)
