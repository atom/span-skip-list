{times, random} = require 'underscore'
SpanSkipList = require '../src/span-skip-list'
ReferenceSpanSkipList = require './reference-span-skip-list'

counter = 1

describe "SpanSkipList", ->
  dimensions = ['x', 'y', 'z']
  buildRandomElement = ->
    x: random(10)
    y: random(10)
    z: random(10)

  buildRandomElements = ->
    elements = []
    times random(10), -> elements.push(buildRandomElement())
    elements

  spliceRandomElements = (lists...) ->
    length = lists[0].getLength('elements')
    index = random(0, length)
    count = random(0, Math.floor((length - index - 1) / 2))
    elements = buildRandomElements()
    dimension = 'elements' #getRandomDimension()
    for list in lists
      list.spliceArray(dimension, index, count, elements)

  getRandomDimension = ->
    dimensions[random(dimensions.length - 1)]

  it "can insert some stuff", ->
    times 10, ->
      list = new SpanSkipList(dimensions...)
      times 10, ->
        spliceRandomElements(list)
        list.verifyDistanceInvariant()

  describe "::totalTo", ->
    it "returns total for all dimensions up to a target total in one dimension", ->
      times 10, ->
        list = new SpanSkipList(dimensions...)
        referenceList = new ReferenceSpanSkipList(dimensions...)
        times 20, -> spliceRandomElements(list, referenceList)

        expect(list.getElements()).toEqual referenceList.getElements()

        list.verifyDistanceInvariant()

        times 10, ->
          dimension = getRandomDimension()
          target = referenceList.getLength(dimension)
          referenceTotal = referenceList.totalTo(target, dimension)
          realTotal = list.totalTo(target, dimension)
          expect(realTotal).toEqual referenceTotal
