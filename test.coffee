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
	f.constant 'C1', { source: 42 }, ['D1', 'D2', 'D3', 'D4', 'D5', 'D6']
	f.decider 'D1', ['source', '<', 43, 'barrel', 1]
	f.decider 'D2', ['source', '=', 42, 'barrel', 1]
	f.decider 'D3', ['source', '>', 41, 'barrel', 1]
	f.decider 'D4', ['source', '<', 41, 'barrel', 1]
	f.decider 'D5', ['source', '=', 43, 'barrel', 1]
	f.decider 'D6', ['source', '>', 43, 'barrel', 1]
	f.tick(1)
	test.object(f.devices.D1.output).is { barrel: 1 }
	test.object(f.devices.D2.output).is { barrel: 1 }
	test.object(f.devices.D3.output).is { barrel: 1 }
	test.object(f.devices.D4.output).is {}
	test.object(f.devices.D5.output).is {}
	test.object(f.devices.D6.output).is {}
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


exports['"anything" conditions'] = ->
	f = new Factorio()
	f.constant 'C1', { source: 42, quest: 5 }, ['D1', 'D2', 'D3', 'D4']
	f.decider 'D1', ['anything', '>', 0,  'light', 1]
	f.decider 'D2', ['anything', '>', 10, 'light', 1]
	f.decider 'D3', ['anything', '>', 43, 'light', 1]
	f.decider 'D4', ['anything', '<', 6,  'light', 1]
	f.tick(1)
	test.object(f.devices.D1.output).is { light: 1 }
	test.object(f.devices.D2.output).is { light: 1 }
	test.object(f.devices.D3.output).is {}
	test.object(f.devices.D4.output).is { light: 1 }
	return


exports['rule validation'] = ->
	test.error ->
		f = new Factorio()
		f.constant 'too-big', {
			'S01': 1, 'S02': 1, 'S03': 1, 'S04': 1, 'S05': 1,
			'S06': 1, 'S07': 1, 'S08': 1, 'S09': 1, 'S10': 1,
			'S11': 1, 'S12': 1, 'S13': 1, 'S14': 1, 'S15': 1,
			'S16': 1
		}
	test.error ->
		f = new Factorio()
		f.arith 'first-arg-is-not-string', [2, '*', 2, 'barrel']
	test.error ->
		f = new Factorio()
		f.arith 'some-weird-rule', ['barrel', '#', 2, 'barrel']
	test.error ->
		f = new Factorio()
		f.arith 'some-weird-rule', ['barrel', '+', {}, 'barrel']
	test.error ->
		f = new Factorio()
		f.decider 'some-weird-rule', [2, '>', 2, 'barrel', 1]
	test.error ->
		f = new Factorio()
		f.decider 'some-weird-rule', ['barrel', '!=', 2, 'barrel', 1]
	test.error ->
		f = new Factorio()
		f.decider 'some-weird-rule', ['barrel', '>', {}, 'barrel', 1]
	test.error ->
		f = new Factorio()
		f.decider 'some-weird-rule', ['barrel', '>', 2, {}, 1]
	test.error ->
		f = new Factorio()
		f.decider 'some-weird-rule', ['barrel', '>', 2, 'barrel', 3]
	return


exports['RS trigger'] = ->
	f = new Factorio()
	# S -> T1 -------------> RS
	# R -> T2 -> T3 -> T4 -> RS
	f.decider 'RS', ['signal', '>', 'reset', 'signal', 1], 'RS'
	f.constant 'S', { signal: 1 }, 'T1'
	f.constant 'R', { reset: 1 }, 'T2'
	f.decider 'T1', ['signal', '>', 0, 'signal', 1], 'RS'
	f.decider 'T2', ['reset', '>', 0, 'reset', 1], 'T3'
	f.decider 'T3', ['reset', '>', 0, 'reset', 1], ['T41', 'T42']
	f.decider 'T41', ['reset', '>', 0, 'reset', 1], 'RS'
	f.decider 'T42', ['reset', '>', 0, 'reset', 1], 'RS'
	f.tick(1)
	test.object(f.devices.RS.output).is {}
	f.tick(1)
	test.object(f.devices.RS.output).is { signal: 1 }
	f.tick(1)
	test.object(f.devices.RS.output).is { signal: 1 }
	f.tick(1)
	test.object(f.devices.RS.output).is {}
	return


exports['Mass arithmetics'] = ->
	f = new Factorio()
	f.constant 'C1', { a: 1, b: 2, c: 3 }, ['A1', 'A2']
	f.arith 'A1', ['each', '*', 3, 'each']
	f.arith 'A2', ['each', '*', 3, 'barrel']
	f.tick(1)
	test.object(f.devices.A1.output).is { a: 3, b: 6, c: 9 }
	test.object(f.devices.A2.output).is { barrel: 18 }
	return
