#!/usr/bin/coffee

Factorio = require './factorio.coffee'
test = require 'unit.js'


exports['should not crash on launch'] = ->
	factorio = new Factorio()
	factorio.tick()
	return


exports.checkId = ->
	factorio = new Factorio()
	factorio.checkId 'test'
	factorio.devices.test = {}
	test.error(-> factorio.checkId 'test')
	return


exports.ensureId = ->
	factorio = new Factorio()
	test.error(-> factorio.ensureId 'test')
	factorio.devices.test = {}
	factorio.ensureId 'test'
	return


exports['constant combinators'] = ->
	f = new Factorio()
	f.constant 'C1', {barrel: 11}, ['C2']
	f.constant 'C2'
	f.tick(1)
	test.object(f.devices.C2.nextInput).is {barrel: 11}
	f.tick(1)
	test.object(f.devices.C2.input).is {barrel: 11}
	return
