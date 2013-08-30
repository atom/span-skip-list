# Span Skip-List [![Build Status](https://travis-ci.org/atom/span-skip-list.png)](https://travis-ci.org/atom/span-skip-list)

This data structure stores arbitrary mappings between various dimensions and
allows running totals to be calculated in O(ln(n)), where n is the number of
table entries. Say you have a table entries like the following:

| x | y |
|-------|
| 3 | 3 |
| 5 | 2 |
| 2 | 7 |
| 4 | 4 |

With this data structure, you can determine how many y's you have traversed when
you've traversed up to a certain number of x's. For example, when you've
traversed up to 8 in the x dimension your total in the y dimension is 5. Here's
an example of how you'd use the span skip list to answer that query:

```coffeescript
SpanSkipList = require 'span-skip-list'

# construct with the dimensions you want to track
list = new SpanSkipList('x', 'y')

# populate with entries. they can be changed at any time
entries = [
  {x: 3, y: 3}
  {x: 5, y: 2}
  {x: 2, y: 7}
  {x: 4, y: 4}
]
list.splice(0, 0, entries...)

# call ::totalTo with a total in one dimension to get a total in all dimensions
list.totalTo(8, 'x') # => { x: 8, y: 5 }
list.totalTo(10, 'x') # => { x: 10, y: 12 }
```
