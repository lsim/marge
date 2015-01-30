define ['app'], (app) ->
  fs = require('fs')

  app.factory 'filesvc', ($q) ->
    (filePath) ->
      deferred = $q.defer()
      fs.readFile filePath, { encoding: 'utf8' }, (err, contents) ->
        if(err)
          deferred.reject(err.message)
        else
          deferred.resolve(contents)
      #return
      deferred.promise

