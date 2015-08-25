#!/usr/bin/coffee

class Factorio

	constructor: ->
		this.devices = {}
		this.registeredSignalTypes = {}


	checkId: (id) ->
		if this.devices[id]?
			throw new Error "ID already taken: #{id}"


	ensureId: (id) ->
		if not this.devices[id]?
			throw new Error "Can't find device: #{id}"


	inspect: (x) ->
		require('util').inspect x, depth: null


	applySignal: (data, id) ->
		#console.log "  -> #{id}: #{this.inspect data}"
		this.ensureId(id)
		targetDevice = this.devices[id]
		for key, value of data
			this.registeredSignalTypes[key] = true
			if not targetDevice.nextInput[key]?
				targetDevice.nextInput[key] = 0
			targetDevice.nextInput[key] += value


	constant: (id, data, outs) ->
		this.checkId(id)
		data = data or {}
		if Object.keys(data).length > 15
			throw new Error "Sunduk cannot carry more than 15 items"
		outs = outs or []
		this.devices[id] = {
			"type": "constant"
			"outs": outs

			"cdata": data

			"input": {}
			"nextInput": {}
		}


	arith: (id, rules, outs) ->
		this.checkId(id)
		rules = rules or []
		outs = outs or []
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
			#console.log "=== TICK #{tick} ==="
			#console.log "Inputs:"
			for id, device of this.devices
				device.input = device.nextInput
				device.nextInput = {}
				#console.log "  #{id}: #{inspect device.input}"
			#console.log "Applying logic"
			for id, device of this.devices
				if device.type is 'constant'
					#console.log "  Device #{id} is constant combinator"
					for out in device.outs
						this.applySignal(device.cdata, out)
				else if device.type is 'arith'
					#console.log "  Device #{id} is arithmetic combinator"
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
						this.applySignal(result, out)
				else if device.type is 'decider'
					#console.log "  Device #{id} is deciding combinator"
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
					result = {}
					result[tmp[3]] = 1
					for out in device.outs
						this.applySignal(result, out)
				else
					throw new Error "Unknown type '#{device.type}' of device #{id}"
			#console.log ""


	dumpRegisteredSignalTypes: ->
		console.log "Registered signal types:"
		for key, value of this.registeredSignalTypes
			console.log "- #{key}"


module.exports = Factorio
