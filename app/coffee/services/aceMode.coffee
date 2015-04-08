define ['app', 'ace/ace', 'ace/ext-modelist'], (app, ace) ->
  modelist = ace.require('ace/ext/modelist')

  app.factory 'aceModeSvc', () ->
    (filePath) ->
      return modelist.getModeForPath(filePath)?.mode

