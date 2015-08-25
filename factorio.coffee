#!/usr/bin/coffee

class Factorio

	constructor: ->
		this.devices = {}
		this.registeredSignalTypes = {}


	checkId: (id) ->
		if this.devices[id]?
			throw new Error "ID already taken: '#{id}'"


	ensureId: (id) ->
		if not this.devices[id]?
			throw new Error "Can't find device: '#{id}'"


	inspect: (x) ->
		require('util').inspect x, depth: null


	applySignal: (data, id) ->
		#console.log "  -> #{id}: #{this.inspect data}"
		this.ensureId(id)
		targetDevice = this.devices[id]
		for key, value of data
			this.registeredSignalTypes[key] = true
			if not targetDevice.input[key]?
				targetDevice.input[key] = 0
			targetDevice.input[key] += value


	constant: (id, data, outs) ->
		this.checkId(id)
		data = data or {}
		if Object.keys(data).length > 15
			throw new Error "Sunduk cannot carry more than 15 items"
		outs = outs or []
		if typeof(outs) is 'string'
			outs = [outs]
		this.devices[id] = {
			"type": "constant"
			"outs": outs

			"cdata": data

			"input": {}
			"output": data
		}


	arith: (id, rules, outs) ->
		this.checkId(id)
		rules = rules or []
		outs = outs or []
		if typeof(outs) is 'string'
			outs = [outs]
		this.devices[id] = {
			"type": "arith"
			"outs": outs

			"rules": rules

			"input": {}
			"nextInput": {}
		}


	decider: (id, rules, outs) ->
		this.checkId(id)
		rules = rules or []
		outs = outs or []
		if typeof(outs) is 'string'
			outs = [outs]
		this.devices[id] = {
			"type": "decider"
			"outs": outs

			"rules": rules

			"input": {}
			"nextInput": {}
		}


	tick: (n) ->
		n = n or 1
		for i in [1..n]
			for id, device of this.devices
				device.input = {}
			for id, device of this.devices
				for out in device.outs
					this.applySignal(device.output, out)
				device.output = {}
			for id, device of this.devices
				if device.type is 'constant'
					device.output = device.cdata
				else if device.type is 'arith'
					tmp = device.rules.slice()
					if typeof tmp[0] is 'string'
						tmp[0] = device.input[tmp[0]] or 0
					if typeof tmp[2] is 'string'
						tmp[2] = device.input[tmp[2]] or 0
					device.output[tmp[3]] = switch tmp[1]
						when '+' then tmp[0]+tmp[2]
						when '-' then tmp[0]-tmp[2]
						when '*' then tmp[0]*tmp[2]
						when '/' then Math.floor(tmp[0]/tmp[2])
						else throw new Error "Unknown operation: #{tmp[1]}"
				else if device.type is 'decider'
					tmp = device.rules.slice()
					if typeof tmp[0] is 'string'
						tmp[0] = device.input[tmp[0]] or 0
					if typeof tmp[2] is 'string'
						tmp[2] = device.input[tmp[2]] or 0
					success = false
					success = switch tmp[1]
						when '<' then tmp[0] < tmp[2]
						when '>' then tmp[0] > tmp[2]
						when '=' then tmp[0] == tmp[2]
						else throw new Error "Unknown operation: #{tmp[1]}"
					device.output[tmp[3]] = 1
				else
					throw new Error "Unknown type '#{device.type}' of device #{id}"


	dumpRegisteredSignalTypes: ->
		console.log "Registered signal types:"
		for key, value of this.registeredSignalTypes
			console.log "- #{key}"


module.exports = Factorio
