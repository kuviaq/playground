import zmq, json

ctx = zmq.Context()
req = ctx.socket(zmq.REQ)
req.connect('tcp://127.0.0.1:5555')


t = json.dumps({'method':'set','arg1':'test_key', 'arg2':'test_value'})
t1 = json.dumps({'method':'get','arg1':'test_key'})

req.send(t)
print req.recv()

req.send(t1)
print req.recv()


test_sproc = '''
	return redis:get("some_key")
'''
t2 = json.dumps({'method':'create_sproc','arg1':'test_sproc', 'arg2':test_sproc})
req.send(t2)
print req.recv()


t3 = json.dumps({'method':'call_sproc','sproc_name':'test_sproc'})
req.send(t3)
print req.recv()

