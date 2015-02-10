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

# Benchmark SpanSkipList::spliceArray
console.profile?('span-skip-list-insert')
start = Date.now()
for offsets in offsetsToInsert
  offsetIndex.spliceArray('rows', 0, offsets.length, offsets)
time = Date.now() - start
console.profileEnd?('span-skip-list-insert')

console.log "Inserting #{lines.length * times} lines took #{time}ms (#{Math.round(lines.length * times / time)} lines/ms)"

# Benchmark SpanSkipList::totalTo
console.profile?('span-skip-list-query')
start = Date.now()
for lineNumber in [0...lines.length * times]
  offsetIndex.totalTo(lineNumber, 'rows')
  offsetIndex.totalTo(lineNumber, 'characters')
time = Date.now() - start
console.profileEnd?('span-skip-list-query')

console.log "Querying #{lines.length * times} lines took #{time}ms (#{Math.round(lines.length * times / time)} lines/ms)"
