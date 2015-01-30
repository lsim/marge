define ['app', 'gui'], (app, gui) ->
  minimist = require('minimist')

  app.controller 'margeController', ($scope) ->

    argv = minimist(gui.App.argv)
    if argv._.length >= 2
      $scope.leftText = argv._[0]
      $scope.rightText = argv._[1]
    else
      $scope.leftText = "invoke with two file paths as arguments"