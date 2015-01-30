define ['app', 'gui', '_', 'services/file', 'services/diff'], (app, gui, _) ->
  minimist = require('minimist')

  app.controller 'margeController', ($scope, filesvc, diffsvc) ->

    argv = minimist(gui.App.argv)
    if argv._.length >= 2
      filesvc(argv._[0]).then (contents) ->
        $scope.leftText = contents
      filesvc(argv._[1]).then (contents) ->
        $scope.rightText = contents
    else
      $scope.leftText = "invoke with two file paths as arguments" # Find better way of displaying this

    $scope.$watch "'' + !!leftText + !!rightText", ->
      return unless $scope.leftText? and $scope.rightText?

      console.log "diff",  diffsvc.diff($scope.leftText, $scope.rightText)

