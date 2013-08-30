{times, random} = require 'underscore'
SpanSkipList = require '../src/span-skip-list'
ReferenceSpanSkipList = require './reference-span-skip-list'

counter = 1

describe "SpanSkipList", ->
  dimensions = ['foos', 'bars', 'bazs']
  buildRandomElement = ->
    {id: counter++, width: random(1, 4)}
    # foos: random(10)
    # bars: random(10)
    # bazs: random(10)

  buildRandomElements = ->
    elements = []
    times 5, -> elements.push(buildRandomElement())
    elements

  spliceRandomElements = (lists...) ->
    length = lists[0].getLength('elements')
    index = random(0, length)
    count = random(0, Math.floor((length - index - 1) / 2))
    elements = buildRandomElements()
    dimension = getRandomDimension()
    for list in lists
      list.spliceArray(dimension, index, count, elements)

  getRandomDimension = ->
    dimensions[random(dimensions.length - 1)]

  fit "can insert some stuff", ->
    realList = new SpanSkipList(dimensions...)

    times 10, ->
      length = realList.getLength('elements')
      index = random(0, length)
      # elements = buildRandomElements()
      # console.log '--------------------'
      # console.log "splicing #{element.id} at", index
      # console.log realList.inspect()
      # console.log "--------------------"
      # realList.splice('elements', index, 0, elements...)
      # console.log realList.inspect()
      # console.log '--------------------'

      spliceRandomElements(realList)
      realList.verifyDistanceInvariant()



  describe "::totalTo", ->
    it "returns total for all dimensions up to a target total in one dimension", ->
      times 1, ->
        realList = new SpanSkipList(dimensions...)
        referenceList = new ReferenceSpanSkipList(dimensions...)
        times 20, -> spliceRandomElements(realList, referenceList)


        # console.log realList.getElements()

        # times 10, ->
          # targetDimension = getRandomDimension()
          # console.log targetDimension
          # targetTotal = random(0, referenceList.getLength(targetDimension))




          # referenceTotal = referenceList.totalTo(targetTotal, targetDimension)
          # realTotal = realList.totalTo(targetTotal, targetDimension)
          #
          # console.log realTotal
          #
          # expect(realTotal).toEqual referenceTotal
