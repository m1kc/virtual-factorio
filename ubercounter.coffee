#!/usr/bin/coffee

Factorio = require './factorio.coffee'
f = new Factorio()

f.arith 'counter', ['global tick number', '+', 1, 'global tick number'], ['counter', 'mirror-1']
f.arith 'mirror-1', ['zero', '-', 'global tick number', 'global tick number'], 'mirror-2'
f.arith 'mirror-2', ['global tick number', '-', 3, 'global tick number'], 'D1'
f.decider 'D1', ['global tick number', '=', -5, 'global tick number', 'keep'], 'counter'

for i in [1..100]
	console.log "Tick #{i}"
	f.tick()
	for key, value of f.devices
		console.log "  #{key}: #{f.inspect value.input} -> #{f.inspect value.output}"
	console.log ''
