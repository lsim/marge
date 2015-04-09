define ['app'], (app) ->
  DiffMatchPatch = require('googlediff')

  app.factory 'diffsvc', () ->
    diff_match_patch = new DiffMatchPatch()
    diff: (file1, file2) ->
      diff_match_patch.diff_main(file1, file2)

    getDmp: ->
      console.warn "Direct access to DMP api!"
      diff_match_patch
