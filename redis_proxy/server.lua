require("zmq")
require("json")
require("redis")

-- Setup zeroMQ socket
local ctx = zmq.init(1)
local s = ctx:socket(zmq.REP)
s:bind("tcp://127.0.0.1:5555")
print("listening on 127.0.0.1:5555")

-- Connect to redis and assign to global
redis = Redis.connect()
print("Connected to localhost redis")

-- Take some action based on incoming msg
function parse_message(msg)
	
	if msg.method == "set" then
		print(string.format("setting: %s", msg.arg1))
		redis:set(msg.arg1, msg.arg2)
		return "OK"
	
	elseif msg.method == "get" then
		print(string.format("getting: %s", msg.arg1))
		return redis:get(msg.arg1)
	
	elseif msg.method == 'create_sproc' then
		print(string.format("Creating sproc: %s", msg.arg1))
		redis:set(msg.arg1, msg.arg2)
		return "OK"

	elseif msg.method == "call_sproc" then
		sp = redis:get(msg.sproc_name)
		sp_f = loadstring(sp)
		return sp_f()

	else
		return "Invalid method"

	end

end


while true do
	t = s:recv()
    print(string.format("Received query: '%s'", t))
    
    j = json.decode(t)
    out = parse_message(j)
    if not out then
    	out = ""
    end
    s:send(out)
end


