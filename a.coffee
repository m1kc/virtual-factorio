#!/usr/bin/coffee

devices = []

constant = (id, data, outs) ->
	devices.push {
		"id": id
		"type": "constant"
		"cdata": data
		"outs": outs
		"input": {}
		"nextInput": {}
	}

# declarations

constant 'C1', {barrel: 5}, ['C3']
constant 'C2', {barrel: 7}, ['C3']
constant 'C3', {}, []

# main

inspect = (x) ->
	require('util').inspect x, depth: null
ticks = 2
for tick in [1..ticks]
	console.log "=== TICK #{tick} ==="
	console.log "Inputs:"
	for device in devices
		device.input = device.nextInput
		device.nextInput = {}
		console.log "  #{device.id}: #{inspect device.input}"
	console.log "Applying logic"
	for device in devices
		console.log "  Working with device #{device.id}"
		if device.type is 'constant'
			console.log "  Device #{device.id} is constant combinator"
			for out in device.outs
				console.log "  Trying to output from #{device.id} to #{out}"
				for targetDevice in devices
					console.log "  Probing #{targetDevice.id}"
					if targetDevice.id is out
						console.log "  #{targetDevice.id} matches"
						for key, value of device.cdata
							console.log "  Applying output piece: #{key} = #{value}"
							if not targetDevice.nextInput[key]?
								targetDevice.nextInput[key] = 0
							targetDevice.nextInput[key] += value
					else
						console.log "  #{targetDevice.id} doesn't match"
	console.log ""
