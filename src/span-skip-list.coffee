{random, clone, isEqual} = require 'underscore'

module.exports =
class SpanSkipList
  maxHeight: 8
  probability: .25

  # Public:
  #
  # * dimensions
  #   A list of strings naming the dimensions to be indexed. Elements should
  #   have numeric-valued properties matching each of the indexed dimensions.
  constructor: (@dimensions...) ->
    @head = new Node(@maxHeight, @buildZeroDistance())
    @tail = new Node(@maxHeight, @buildZeroDistance())
    for i in [0...@maxHeight]
      @head.next[i] = @tail
      @head.distance[i] = @buildZeroDistance()

  # Public: Returns the total in all dimensions for elements adding up to the
  # given target value in the given dimension.
  totalTo: (target, dimension) ->
    totalDistance = @buildZeroDistance()
    node = @head

    for i in [@maxHeight - 1..0]
      loop
        break if node.next[i] is @tail

        nextDistanceInTargetDimension =
          totalDistance[dimension] +
            node.distance[i][dimension] +
              (node.next[i].element[dimension] ? 1)

        break if nextDistanceInTargetDimension > target

        @incrementDistance(totalDistance, node.distance[i])
        @incrementDistance(totalDistance, node.next[i].element)

        node = node.next[i]

    totalDistance

  # Public: Splices into the list in a given dimension.
  #
  # * dimension
  #   The dimension in which to interpret the insertion index.
  # * index
  #   The index at which to start removing/inserting elements.
  # * count
  #   The number of elements to remove, starting at the given index.
  # * elements...
  #   Elements to insert, starting at the given index.
  splice: (dimension, index, count, elements...) ->
    @spliceArray(dimension, index, count, elements)

  # Public: Works just like splice, but takes an array of elements to insert
  # instead of multiple arguments.
  spliceArray: (dimension, index, count, elements) ->
    previous = @buildPreviousArray()
    previousDistances = @buildPreviousDistancesArray()

    nextNode = @findClosestNode(dimension, index, previous, previousDistances)

    # Remove count nodes and decrement totals for updated pointers
    removedElements = []

    while count > 0
      removedElements.push(nextNode.element)
      nextNode = @removeNode(nextNode, previous, previousDistances)
      count--

    # Insert new nodes and increment totals for updated pointers
    i = elements.length - 1
    while i >= 0
      element = elements[i]
      newNode = new Node(@getRandomNodeHeight(), element)
      @insertNode(newNode, previous, previousDistances)
      i--

    removedElements

  getLength: ->
    @getElements().length

  # Public: Returns all elements in the list.
  getElements: ->
    elements = []
    node = @head
    while node.next[0] isnt @tail
      elements.push(node.next[0].element)
      node = node.next[0]
    elements

  # Private: Searches the list in a stairstep descent, following the highest
  # path that doesn't overshoot the index.
  #
  # * previous
  #   An array that will be populated with the last node visited at every level.
  # * previousDistances
  #   An array that will be populated with the distance of forward traversal
  #   at each level.
  #
  # Returns the leftmost node whose running total in the target dimension
  # exceeds the target index
  findClosestNode: (dimension, index, previous, previousDistances) ->
    totalDistance = @buildZeroDistance()
    node = @head
    for i in [@maxHeight - 1..0]
      # Move forward as far as possible while keeping the running total in the
      # target dimension less than or equal to the target index.
      loop
        break if node.next[i] is @tail

        nextHopDistance = (node.next[i].element[dimension] ? 1) + node.distance[i][dimension]
        break if totalDistance[dimension] + nextHopDistance > index

        @incrementDistance(totalDistance, node.distance[i])
        @incrementDistance(totalDistance, node.next[i].element)
        @incrementDistance(previousDistances[i], node.distance[i])
        @incrementDistance(previousDistances[i], node.next[i].element)

        node = node.next[i]

      # Record the last node visited at the current level before dropping to the
      # next level.
      previous[i] = node
    node.next[0]

  # Private: Inserts the given node in the list and updates distances
  # accordingly.
  #
  # * previous
  #   An array of the last node visited at each level during the traversal to
  #   the insertion site.
  # * previousDistances
  #   An array of the distances traversed at each level during the traversal to
  #   the insertion site.
  insertNode: (node, previous, previousDistances) ->
    coveredDistance = @buildZeroDistance()

    for level in [0...node.height]
      node.next[level] = previous[level].next[level]
      previous[level].next[level] = node
      node.distance[level] = @subtractDistances(previous[level].distance[level], coveredDistance)
      previous[level].distance[level] = clone(coveredDistance)
      @incrementDistance(coveredDistance, previousDistances[level])

    for level in [node.height...@maxHeight]
      @incrementDistance(previous[level].distance[level], node.element)

  # Private: Removes the given node and updates the distances of nodes to the
  # left. Returns the node following the removed node.
  removeNode: (node, previous) ->
    for level in [0...node.height]
      previous[level].next[level] = node.next[level]
      @incrementDistance(previous[level].distance[level], node.distance[level])

    for level in [node.height...@maxHeight]
      @decrementDistance(previous[level].distance[level], node.element)

    node.next[0]

  # Private: The previous array stores references to the last node visited at
  # each level when traversing to a node.
  buildPreviousArray: ->
    previous = new Array(@maxHeight)
    previous[i] = @head for i in [0...@maxHeight]
    previous

  # Private: The previous distances array stores the distance traversed at each
  # level when traversing to a node.
  buildPreviousDistancesArray: ->
    distances = new Array(@maxHeight)
    distances[i] = @buildZeroDistance() for i in [0...@maxHeight]
    distances

  # Private: Returns a height between 1 and maxHeight (inclusive). Taller heights
  # are logarithmically less probable than shorter heights because each increase
  # in height requires us to win a coin toss weighted by @probability.
  getRandomNodeHeight: ->
    height = 1
    height++ while height < @maxHeight and Math.random() < @probability
    height

  # Private
  buildZeroDistance: ->
    distance = {elements: 0}
    distance[dimension] = 0 for dimension in @dimensions
    distance

  # Private
  incrementDistance: (distance, delta) ->
    distance.elements += delta.elements ? 1
    distance[dimension] += delta[dimension] for dimension in @dimensions

  # Private
  decrementDistance: (distance, delta) ->
    distance.elements -= delta.elements ? 1
    distance[dimension] -= delta[dimension] for dimension in @dimensions

  # Private
  addDistances: (a, b) ->
    distance = {elements: (a.elements ? 1) + (b.elements ? 1)}
    for dimension in @dimensions
      distance[dimension] = a[dimension] + b[dimension]
    distance

  # Private
  subtractDistances: (a, b) ->
    distance = {elements: (a.elements ? 1) - (b.elements ? 1)}
    for dimension in @dimensions
      distance[dimension] = a[dimension] - b[dimension]
    distance

  # Private: Test only. Verifies that the distances at each level match the
  # combined distances of nodes on the levels below.
  verifyDistanceInvariant: ->
    for level in [@maxHeight - 1..1]
      node = @head
      while node isnt @tail
        distanceOnThisLevel = @addDistances(node.element, node.distance[level])
        distanceOnPreviousLevel = @distanceBetweenNodesAtLevel(node, node.next[level], level - 1)
        unless isEqual(distanceOnThisLevel, distanceOnPreviousLevel)
          console.log @inspect()
          throw new Error("On level #{level}: Distance #{JSON.stringify(distanceOnThisLevel)} does not match #{JSON.stringify(distanceOnPreviousLevel)}")
        node = node.next[level]

  # Private
  distanceBetweenNodesAtLevel: (startNode, endNode, level) ->
    distance = @buildZeroDistance()
    node = startNode
    while node isnt endNode
      @incrementDistance(distance, node.element)
      @incrementDistance(distance, node.distance[level])
      node = node.next[level]
    distance

class Node
  constructor: (@height, @element) ->
    @next = new Array(@height)
    @distance = new Array(@height)
