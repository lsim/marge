define ['app', 'ace/ace', 'ace/ext-modelist'], (app, ace) ->
  fs = require('fs')
  path = require('path')
  modelist = ace.require('ace/ext/modelist')

  app.factory 'filesvc', ($q) ->
    (filePath) ->
      deferred = $q.defer()
      absPath = path.resolve(filePath)
      console.debug "resolved file path ", absPath, filePath
      fs.readFile absPath, { encoding: 'utf8' }, (err, contents) ->
        if(err)
          deferred.reject(err.message)
        else
          deferred.resolve(contents)
      #return
      deferred.promise

