{times, random} = require 'underscore'
SpanSkipList = require '../src/span-skip-list'
ReferenceSpanSkipList = require './reference-span-skip-list'

describe "SpanSkipList", ->
  dimensions = ['foos', 'bars', 'bazs']
  buildRandomElement = ->
    foos: random(10)
    bars: random(10)
    bazs: random(10)

  buildRandomElements = ->
    elements = []
    times random(10), -> elements.push(buildRandomElement())
    elements

  spliceRandomElements = (realList, referenceList) ->
    index = random(0, referenceList.getLength('elements'))
    count = random(0, Math.floor((referenceList.getLength('elements') - index) / 2))
    elements = buildRandomElements()
    dimension = getRandomDimension()
    realList.spliceArray(dimension, index, count, elements)
    referenceList.spliceArray(dimension, index, count, elements)

  getRandomDimension = ->
    dimensions[random(dimensions.length - 1)]

  describe "::totalTo", ->
    it "returns total for all dimensions up to a target total in one dimension", ->
      times 1, ->
        realList = new SpanSkipList(dimensions...)
        referenceList = new ReferenceSpanSkipList(dimensions...)
        times 20, -> spliceRandomElements(realList, referenceList)
        times 10, ->
          targetDimension = getRandomDimension()
          console.log targetDimension
          targetTotal = random(0, referenceList.getLength(targetDimension))

          referenceTotal = referenceList.totalTo(targetTotal, targetDimension)
          realTotal = realList.totalTo(targetTotal, targetDimension)

          console.log realTotal

          expect(realTotal).toEqual referenceTotal
