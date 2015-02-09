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

offsetsToInsert = []
while count < times
  offsetsToInsert.push lines.map (line, index) -> {rows: 1, characters: line.length + 1}
  lines = _.shuffle(lines)
  count++

start = Date.now()
for offsets in offsetsToInsert
  offsetIndex.spliceArray('rows', 0, offsets.length, offsets)
time = Date.now() - start

console.log "Inserting #{lines.length * times} lines took #{time}ms (#{Math.round(lines.length * times / time)} lines/ms)"
