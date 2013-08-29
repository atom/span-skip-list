module.exports =
class SpanSkipList
  maxHeight: 8
  probability: .5

  constructor: (@dimensions...) ->
    @head = new Node(@maxHeight, -Infinity)
    @tail = new Node(@maxHeight, Infinity)
    for i in [0...@maxHeight]
      @head.next[i] = @tail
      @head.distance[i] = 1
      @tail.distance[i] = 0

  # totalTo: (targetTotal, targetDimension) ->
  #   total = @buildZeroDistance()
  #   i = 0
  #   while i < @nodes.length
  #     current = @nodes[i]
  #     break if total[targetDimension] + current.distance[targetDimension] > targetTotal
  #     @incrementDistance(total, current)
  #     i++
  #   total

  splice: (targetDimension, targetIndex, count, elements...) ->
    @spliceArray(targetDimension, targetIndex, count, elements)

  spliceArray: (targetDimension, targetIndex, count, elements) ->
    previous = @buildPreviousArray()
    previousDistances = @buildPreviousDistancesArray()

    nextNode = @findClosestNode(targetDimension, targetIndex, previous, previousDistances)

    # Remove count nodes and decrement totals for updated pointers
    while count > 0
      nextNode = @removeNode(nextNode, previous, previousDistances)
      count--

    # Insert new nodes and increment totals for updated pointers
    i = elements.length - 1
    while i >= 0
      newNode = new Node(@getRandomNodeHeight(), elements[i])
      @insertNode(newNode, previous, previousDistances)
      i--

  getLength: ->
    @getElements().length

  getElements: ->
    @getNodes().map (node) -> node.element

  getNodes: ->
    nodes = [@head]
    node = @head
    while node isnt @tail
      nodes.push(node.next[0])
      node = node.next[0]
    nodes

  removeNode: (node, previous) ->
    for level in [0...node.height]
      previous[level].next[level] = node.next[level]
      previous[level].distance[level] += node.distance[level] - 1

    for level in [node.height...@maxHeight]
      previous[level].distance[level]--

    node.next[0]

  insertNode: (node, previous, previousDistances) ->
    coveredDistance = 0
    for level in [0...node.height]
      node.next[level] = previous[level].next[level]
      previous[level].next[level] = node
      node.distance[level] = previous[level].distance[level] - coveredDistance
      previous[level].distance[level] = coveredDistance + 1
      coveredDistance += previousDistances[level]

    for level in [node.height...@maxHeight]
      previous[level].distance[level] += 1

  # Private: Searches the skiplist in a stairstep descent, following the highest
  # path that doesn't overshoot the index.
  #
  # * next
  #   An array that will be populated with the last node visited at every level
  #
  # Returns the leftmost node whose running total in the target dimension
  # exceeds the target index
  findClosestNode: (targetDimension, index, previous, previousDistances) ->
    totalDistance = 0
    node = @head
    for i in [@maxHeight - 1..0]
      # Move forward as far as possible while keeping the running total in the
      # target dimension less than or equal to the target index.
      loop
        break if node.next[i] is @tail
        break if totalDistance + node.distance[i] > index
        totalDistance += node.distance[i]
        previousDistances[i] += node.distance[i]
        node = node.next[i]

      # Record the last node visited at the current level before dropping to the
      # next level.
      previous?[i] = node
    node.next[0]

  # Private
  buildPreviousArray: ->
    previous = new Array(@maxHeight)
    previous[i] = @head for i in [0...@maxHeight]
    previous

  buildPreviousDistancesArray: ->
    distances = new Array(@maxHeight)
    distances[i] = 0 for i in [0...@maxHeight]
    distances

  # Private: Returns a height between 1 and maxHeight (inclusive). Taller heights
  # are logarithmically less probable than shorter heights because each increase
  # in height requires us to win a coin toss weighted by @probability.
  getRandomNodeHeight: ->
    height = 1
    height++ while height < @maxHeight and Math.random() < @probability
    height

  buildZeroDistance: ->
    distance = {elements: 0}
    distance[dimension] = 0 for dimension in @dimensions
    distance

  incrementDistance: (distance, delta) ->
    distance.elements++
    distance[dimension] += delta[dimension] for dimension in @dimensions

  decrementDistance: (distance, delta) ->
    distance.elements--
    distance[dimension] -= delta[dimension] for dimension in @dimensions

  addDistances: -> (a, b) ->
    distance = {}
    for dimension in @dimensions
      distance[dimension] = a[dimension] + b[dimension]
    distance

  subtractDistances: -> (a, b) ->
    distance = {}
    for dimension in @dimensions
      distance[dimension] = a[dimension] - b[dimension]
    distance

  verifyDistanceInvariant: ->
    for level in [@maxHeight - 1..1]
      node = @head
      while node isnt @tail
        distanceOnThisLevel = node.distance[level]
        distanceOnPreviousLevel = @distanceBetweenNodesAtLevel(node, node.next[level], level - 1)
        if distanceOnThisLevel isnt distanceOnPreviousLevel
          throw new Error("On level #{level}: Distance #{distanceOnThisLevel} does not match #{distanceOnPreviousLevel}")
        node = node.next[level]

  distanceBetweenNodesAtLevel: (startNode, endNode, level) ->
    distance = 0
    node = startNode
    while node isnt endNode
      distance += node.distance[level]
      node = node.next[level]
    distance

class Node
  constructor: (@height, @element) ->
    @next = new Array(@height)
    @distance = new Array(@height)
