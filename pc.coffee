#!/usr/bin/coffee

TACT_LENGTH = 20

Factorio = require './factorio.coffee'
f = new Factorio()

# super counter
f.arith 'counter', ['global tick number', '+', 1, 'global tick number'], ['counter', 'T1-rep', 'T1-d10']
# cycled counter from 0 to TACT_LENGTH-1
f.arith 'T1-d10', ['global tick number', '/', TACT_LENGTH, 'tmp'], 'T2-x10'
f.decider 'T1-rep', ['anything', '>', 0, 'everything', 'keep'], 'T2-rep'
f.arith 'T2-x10', ['tmp', '*', TACT_LENGTH, 'tmp'], 'T3-res'
f.decider 'T2-rep', ['anything', '>', 0, 'everything', 'keep'], 'T3-res'
f.arith 'T3-res', ['global tick number', '-', 'tmp', 'local tick number'], 'address incrementor'
# address register
f.arith 'address', ['address', '+', 'address increment', 'address'], ['address']
# address incrementor - works on tick 1
f.decider 'address incrementor', ['local tick number', '=', 1, 'address increment', 1], 'address'
# memory
memory = [
	{ 'write register 1': 7 }
	{ 'write register 2': 9 }
]
for value, key in memory
	num = key+1
	f.constant "memory cell #{num}", value, "memory reader #{num}"
	f.decider "memory reader #{num}", ['address', '=', num, 'everything', 'keep'], 'memory output'
	f.devices.address.outs.push "memory reader #{num}"
# memory ends here
f.decider 'memory output', ['anything', '>', 0, 'everything', 'keep']

for i in [1..TACT_LENGTH*memory.length]
	console.log "Tick #{i}"
	f.tick()
	for key, value of f.devices
		console.log "  #{key}: #{f.inspect value.input} -> #{f.inspect value.output}"
	console.log ''

console.log ''
f.dumpRegisteredSignalTypes()
