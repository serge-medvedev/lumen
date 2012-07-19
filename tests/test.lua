--- A sample program that uses the scheduler to do stuff.

--require "strict"

--look for packages one folder up.
package.path = package.path .. ";;;../?.lua"


local sched = require "sched"
--require "log".setlevel('ALL')
local catalog = require 'catalog'


sched.run(function()
	catalog.register('main')
	local A=sched.run(function()
		catalog.register('A')
		sched.sleep(2)
		print("A says: emittig 'ev, data!'")
		sched.signal('ev', 'data!')
		print("A says: finishing")
	end)
	local B=sched.run(function()
		catalog.register('B')
		local A = catalog.waitfor('A')
		print ("B says: A found at", A)
		print ("B says: waiting for a 'die' from A")
		local _, _, status = sched.wait({emitter=A, events={sched.EVENT_DIE}})
		print ("B says: received a 'die' from A")
		print ("B says: going to error with message 'xxx'")
		error('xxx')
	end)

	print ("0 says: waiting for a 'ev' from A")
	local _, _, x = sched.wait({emitter=A, events={'ev'}})
	print ("0 says: received a 'ev' from A, with a", x)
	print ("0 says: going to kill A")
	sched.kill(A)

	print("0 says: finishing, returning", x)
	return x
end)


sched.go()
