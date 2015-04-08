define [], ->

  return unless window.console?
  stringify = require('json-stringify-safe')
  fs = require('fs')

  overrideLogLevel = (level) ->
    return unless console[level]?

    boundOriginal = console[level].bind(console)
    doLog = (args...) ->
      logLine = level + " " + args.map((o) -> stringify(o, null, 2)).join(",")
      boundOriginal?(logLine)
      fs.appendFile 'marge.log', logLine, (err) ->

    console[level] = doLog

  overrideLogLevel 'debug'
  overrideLogLevel 'log'
  overrideLogLevel 'warn'
  overrideLogLevel 'error'



