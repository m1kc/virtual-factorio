#!/usr/bin/coffee

Factorio = require './factorio.coffee'
test = require 'unit.js'

exports['should not crash on launch'] = ->
	factorio = Factorio()
	factorio.tick()
	return

exports.checkId = ->
	factorio = Factorio()
	factorio.checkId 'test'
	factorio.devices.test = {}
	test.exception(-> factorio.checkId 'test')
	return
