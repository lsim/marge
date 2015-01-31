define ['foo', 'bar'], (foo, bar) ->

  logTheFoo: () ->
    console.log 'foo', foo

  logTheBar: () ->
    console.log 'bar', bar

  logSomethingElse: () ->
    console.log 43
