define ['app', 'ace/ace'], (app) ->
  fs = require('fs')
  path = require('path')

  app.factory 'filesvc', ($q) ->
    (filePath) ->
      deferred = $q.defer()
      absPath = path.resolve(filePath)
      console.debug "resolved file path", absPath, filePath
      fs.readFile absPath, { encoding: 'utf8' }, (err, contents) ->
        if(err)
          deferred.reject(err.message)
        else
          deferred.resolve(contents)
      #return
      deferred.promise

