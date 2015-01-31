define ['app', 'gui', '_',
        'services/file',
        'services/diff',
        'services/aceMode',
        'services/highlight'
], (app, gui, _) ->
  minimist = require('minimist')

  # This is the outermost controller of the application. It parses command line arguments etc

  app.controller 'margeController', ($scope, filesvc, diffsvc, aceModesvc, highlightsvc) ->

    argv = minimist(gui.App.argv)
    if argv._.length >= 2
      $scope.leftPath = argv._[0]
      $scope.rightPath = argv._[1]

      filesvc($scope.leftPath).then (contents) ->
        $scope.leftContent =
          text: contents
          mode: aceModesvc($scope.leftPath)
      filesvc($scope.rightPath).then (contents) ->
        $scope.rightContent =
          text: contents
          mode: aceModesvc($scope.rightPath)
    else
      $scope.leftText = "invoke with two file paths as arguments" # Find better way of displaying this

    $scope.$watch "'' + !!leftContent + !!rightContent", ->
      return unless $scope.leftContent? and $scope.rightContent?
      differences = diffsvc.diff($scope.leftContent.text, $scope.rightContent.text)
      leftHighlights = highlightsvc(differences, -1)
      rightHighlights = highlightsvc(differences, 1)

      $scope.leftContent.highlights = leftHighlights
      $scope.rightContent.highlights = rightHighlights


