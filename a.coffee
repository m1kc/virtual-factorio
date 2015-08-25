#!/usr/bin/coffee

devices = {}
signalTypes = {}

checkId = (id) ->
	if devices[id]?
		throw new Error "ID already taken: #{id}"

ensureId = (id) ->
	if not devices[id]?
		throw new Error "Can't find device: #{id}"

constant = (id, data, outs) ->
	checkId(id)
	data = data or {}
	if Object.keys(data).length > 15
		throw new Error "Sunduk cannot carry more than 15 items"
	outs = outs or []
	devices[id] = {
		"type": "constant"
		"outs": outs
		
		"cdata": data
		
		"input": {}
		"nextInput": {}
	}

arith = (id, rules, outs) ->
	checkId(id)
	rules = rules or []
	outs = outs or []
	devices[id] = {
		"type": "arith"
		"outs": outs
		
		"rules": rules
		
		"input": {}
		"nextInput": {}
	}

# utils

inspect = (x) ->
	require('util').inspect x, depth: null

# work

apply = (data, id) ->
	console.log "  -> #{id}: #{inspect data}"
	ensureId(id)
	targetDevice = devices[id]
	for key, value of data
		signalTypes[key] = true
		if not targetDevice.nextInput[key]?
			targetDevice.nextInput[key] = 0
		targetDevice.nextInput[key] += value

# declarations

constant 'C1', {barrel: 5}, ['C3']
constant 'C2', {barrel: 7}, ['C3']
constant 'C3'

constant 'C4', {a: 11, b: 77}, ['A1']
arith 'A1', ['a', '+', 'b', 'barrel'], ['C5']
constant 'C5'

arith 'counter', ['empty-barrel', '+', 1, 'empty-barrel'], ['counter']

# main

TICKS = 3
	
for tick in [1..TICKS]
	console.log "=== TICK #{tick} ==="
	console.log "Inputs:"
	for id, device of devices
		device.input = device.nextInput
		device.nextInput = {}
		console.log "  #{id}: #{inspect device.input}"
	console.log "Applying logic"
	for id, device of devices
		if device.type is 'constant'
			console.log "  Device #{id} is constant combinator"
			for out in device.outs
				apply(device.cdata, out)
		else if device.type is 'arith'
			console.log "  Device #{id} is arithmetic combinator"
			tmp = device.rules.slice()
			if typeof tmp[0] is 'string'
				tmp[0] = device.input[tmp[0]] or 0
			if typeof tmp[2] is 'string'
				tmp[2] = device.input[tmp[2]] or 0
			result = {}
			result[tmp[3]] = switch tmp[1]
				when '+' then tmp[0]+tmp[2]
				when '-' then tmp[0]-tmp[2]
				when '*' then tmp[0]*tmp[2]
				when '/' then tmp[0]/tmp[2]
				else throw new Error "Unknown operation: #{tmp[1]}"
			for out in device.outs
				apply(result, out)
		else
			throw new Error "Unknown type '#{device.type}' of device #{id}"
	console.log ""

console.log "Registered signal types:"
for key, value of signalTypes
	console.log "- #{key}"
