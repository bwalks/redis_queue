local queue_name = KEYS[1]
local in_flight_queue_name = queue_name .. ':inflight'
local message_ttl_format = queue_name .. ':%s:ttl'
local response_message_id = nil
local ttl = tonumber(redis.call('get', queue_name .. ':ttl'))


-- See if first in-flight message needs to be processed
local in_flight = redis.call('lrange', in_flight_queue_name, 0, 0)

if #in_flight > 0 then
	local in_flight_id = in_flight[1]
	if redis.call('exists', string.format(message_ttl_format, in_flight_id)) == 0 then
		-- If TTL check has expired and the message not deleted, return it
		if redis.call('exists', queue_name .. ':' .. in_flight_id) == 1 then
			response_message_id = in_flight_id
			redis.call('lpop', in_flight_queue_name)
		end
	end
end

if not response_message_id then
	-- Get next message from regular queue if we didn't get one from the in-flight queue
	response_message_id = redis.call('lpop', queue_name)
	if not response_message_id then
		return nil
	end
end

-- Add this message to the in-flight queue
redis.call('rpush', in_flight_queue_name, response_message_id)
local message_ttl_key = string.format(message_ttl_format, response_message_id)
redis.call('set', message_ttl_key, 1)
redis.call('expire', message_ttl_key, ttl)

return {
	response_message_id, 
	redis.call('get', queue_name .. ':' .. response_message_id)
}