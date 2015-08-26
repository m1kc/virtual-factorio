#!/bin/bash
./node_modules/mocha/bin/mocha \
  --ui=exports \
  -r ./node_modules/coffee-script/lib/coffee-script/register.js \
  test.coffee
