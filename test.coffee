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


exports['single constant combinator'] = ->
	f = new Factorio()
	f.constant 'C1', { barrel: 11 }
	test.object(f.devices.C1.output).is { barrel: 11 }
	f.tick(1)
	test.object(f.devices.C1.output).is { barrel: 11 }
	return


exports['two chained constant combinators'] = ->
	f = new Factorio()
	f.constant 'C1', { barrel: 11 }, 'C2'
	f.constant 'C2', { barrel: 22 }
	f.tick(1)
	test.object(f.devices.C1.input).is {}
	test.object(f.devices.C1.output).is { barrel: 11 }
	test.object(f.devices.C2.input).is { barrel: 11 }
	test.object(f.devices.C2.output).is { barrel: 22 }
	return


exports['basic arithmetics'] = ->
	f = new Factorio()
	f.constant 'C1', { source: 42 }, ['A1', 'A2', 'A3', 'A4', 'A5']
	f.arith 'A1', ['source', '+', 2, 'result'], []
	f.arith 'A2', ['source', '-', 2, 'result'], []
	f.arith 'A3', ['source', '*', 2, 'result'], []
	f.arith 'A4', ['source', '/', 2, 'result'], []
	f.arith 'A5', ['source', '/', 10, 'result'], []
	f.tick(1)
	test.object(f.devices.A1.output).is { result: 44 }
	test.object(f.devices.A2.output).is { result: 40 }
	test.object(f.devices.A3.output).is { result: 84 }
	test.object(f.devices.A4.output).is { result: 21 }
	test.object(f.devices.A5.output).is { result: 4 }
	return


exports['basic decision making'] = ->
	f = new Factorio()
	f.constant 'C1', { source: 42 }, ['D1', 'D2', 'D3']
	f.decider 'D1', ['source', '<', 43, 'barrel', 1]
	f.decider 'D2', ['source', '=', 42, 'barrel', 1]
	f.decider 'D3', ['source', '>', 41, 'barrel', 1]
	f.tick(1)
	test.object(f.devices.D1.output).is { barrel: 1 }
	test.object(f.devices.D2.output).is { barrel: 1 }
	test.object(f.devices.D3.output).is { barrel: 1 }
	return


exports['simple remainder device'] = ->
	f = new Factorio()
	f.constant 'source', { barrel: 42 }, ['d10', 'rem']
	f.arith 'd10', ['barrel', '/', 10, 'black-barrel'], 'x10'
	f.arith 'x10', ['black-barrel', '*', 10, 'black-barrel'], 'rem'
	f.arith 'rem', ['barrel', '-', 'black-barrel', 'barrel']
	f.tick(3)
	test.object(f.devices.rem.output).is { barrel: 2 }
	f.tick(1)
	test.object(f.devices.rem.output).is { barrel: 2 }
	f.tick(1)
	test.object(f.devices.rem.output).is { barrel: 2 }
	return


exports['fast endless counter'] = ->
	f = new Factorio()
	f.arith 'counter', ['barrel', '+', 1, 'barrel'], 'counter'
	f.tick(1)
	test.object(f.devices.counter.output).is { barrel: 1 }
	f.tick(1)
	test.object(f.devices.counter.output).is { barrel: 2 }
	f.tick(1)
	test.object(f.devices.counter.output).is { barrel: 3 }
	return