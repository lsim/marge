define ['app', 'ace/ace', 'ace/ext-modelist'], (app, ace) ->
  fs = require('fs')
  modelist = ace.require('ace/ext/modelist')

  app.factory 'aceModesvc', () ->
    (filePath) ->
      return modelist.getModeForPath(filePath)?.mode

