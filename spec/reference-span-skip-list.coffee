{clone} = require 'underscore'

# Test-only: This is a simple linear reference implementation of the behavior
# we want from the real skip-list-based implementation.
module.exports =
class ReferenceSpanSkipList
  constructor: (@dimensions...) ->
    @nodes = []

  splice: (targetDimension, targetIndex, count, nodes...) ->
    @spliceArray(targetDimension, targetIndex, count, nodes)

  spliceArray: (targetDimension, targetIndex, count, nodes) ->
    index = @totalTo(targetIndex, targetDimension).elements
    @nodes.splice(index, count, nodes...)

  totalTo: (targetTotal, targetDimension) ->
    total = @buildInitialTotal()
    i = 0
    while i < @nodes.length
      current = @nodes[i]
      break if total[targetDimension] + (current[targetDimension] ? 1) > targetTotal
      @incrementTotal(total, current)
      i++
    total

  getElements: -> clone(@nodes)

  getLength: (dimension) ->
    @totalTo(Infinity, dimension)[dimension]

  buildInitialTotal: ->
    total = {elements: 0}
    total[dimension] = 0 for dimension in @dimensions
    total

  incrementTotal: (total, node) ->
    total.elements++
    total[dimension] += node[dimension] for dimension in @dimensions
