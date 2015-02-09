#!/usr/bin/env coffee

fs = require 'fs'
path = require 'path'
SpanSkipList = require '../src/span-skip-list'
_ = require 'underscore'

lines = fs.readFileSync(path.join(__dirname, 'large.js'), 'utf8').split('\n')
offsetIndex = new SpanSkipList('rows', 'characters')

times = 25
count = 0
time = 0

while count < times
  offsets = lines.map (line, index) -> {rows: 1, characters: line.length + 1}
  start = Date.now()
  offsetIndex.spliceArray('rows', 0, lines.length, offsets)
  time += Date.now() - start
  lines = _.shuffle(lines)
  count++

console.log "Inserting #{lines.length * times} lines took #{time}ms (#{Math.round(lines.length * times / time)} lines/ms)"
