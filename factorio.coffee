#!/usr/bin/coffee

module.exports = ->
	factorio = {}
	
	# general storage
	factorio.devices = {}
	# for debugging
	factorio.registeredSignalTypes = {}
	
	# functions
	
	factorio.checkId = (id) ->
		if factorio.devices[id]?
			throw new Error "ID already taken: #{id}"

	factorio.ensureId = (id) ->
		if not factorio.devices[id]?
			throw new Error "Can't find device: #{id}"
	
	# ...and here we go
	factorio.tick = -> 'ok'
	return factorio
