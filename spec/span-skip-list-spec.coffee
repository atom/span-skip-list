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

  buildRandomElements = (count=random(10)) ->
    elements = []
    times count, -> elements.push(buildRandomElement())
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

  describe "::splice(dimension, index, count, elements...)", ->
    it "maintains the distance invariant when removing / inserting elements", ->
      times 10, ->
        list = new SpanSkipList(dimensions...)
        times 10, ->
          spliceRandomElements(list)
          list.verifyDistanceInvariant()

    it "returns an array of removed elements", ->
      list = new SpanSkipList(dimensions...)
      elements = buildRandomElements(10)
      list.spliceArray('elements', 0, 0, elements)
      expect(list.splice('elements', 3, 2)).toEqual elements[3..4]

    it "does not attempt to remove beyond the end of the list", ->
      list = new SpanSkipList(dimensions...)
      elements = buildRandomElements(10)
      list.spliceArray('elements', 0, 0, elements)
      expect(list.splice('elements', 9, 3)).toEqual elements[9..9]
