define ['app', 'ace/ace', 'ace/ext-modelist'], (app, ace) ->
  modelist = ace.require('ace/ext/modelist')

  app.factory 'aceModesvc', () ->
    (filePath) ->
      return modelist.getModeForPath(filePath)?.mode

