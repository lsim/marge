define ['app', '_', 'menu/mainMenu', 'diffEngines/googleDmp',
        'services/file',
        'services/aceMode'
], (app, _, menu, diff) ->
  minimist = require('minimist')
  mainProcess = require('remote').process

  # This is the outermost controller of the application. It parses command line arguments etc

  app.controller 'margeController', ($scope, filesvc, aceModeSvc) ->
    console.debug "command line arguments", mainProcess.argv
    argv = minimist(mainProcess.argv)
    if argv._.length >= 3
      filePaths = _.takeRight(argv._, 3) # Take the last three arguments
      loadPath = (panelName, path, displayName) ->
        filesvc(path).then((contents) ->
          $scope[panelName + 'Content'] =
            text: contents
            mode: aceModeSvc(path)
            path: path
            name: displayName
        , (err) -> console.error "Failed loading file", err)
      loadPath('base', filePaths[0], 'Base')
      loadPath('future1', filePaths[1], 'Future 1')
      loadPath('future2', filePaths[2], 'Future 2')
    else
      $scope.baseContent =
        text: "invoke with three file paths (base, future1, future2) as arguments" # Find better way of displaying this
        name: "Error"

    $scope.editorSettings =
      theme: "monokai"

    updateThreeWayMerge = _.debounce(->
      return unless $scope.baseContent? and $scope.future1Content? and $scope.future2Content?
      {base, future1, future2, result} = diff.threeWayMerge($scope.baseContent.text, $scope.future1Content.text, $scope.future2Content.text)
      $scope.resultContent =
        text: result.text
        mode: $scope.future1Content.mode
        name: "Result"
        path: result.statusText
#        highlights: result.highlights
#      $scope.future1Content.highlights = future1.highlights
      $scope.future1Content.chunks = future1.chunks
#      $scope.future2Content.highlights = future2.highlights
      $scope.future2Content.chunks = future2.chunks
#      $scope.baseContent.highlights = base.highlights
      $scope.$apply()
    , 50)

    $scope.$watch "baseContent.text", updateThreeWayMerge
    $scope.$watch "future1Content.text", updateThreeWayMerge
    $scope.$watch "future2Content.text", updateThreeWayMerge

    $scope.themeStyle = { backgroundColor: 'white', color: 'black' }
    $scope.$on 'marge:theme-style-change', (event, style) ->
      if $scope.themeStyle.backgroundColor == style.backgroundColor and $scope.themeStyle.color == style.color
        return
      $scope.themeStyle.backgroundColor = style.backgroundColor
      $scope.themeStyle.color = style.color

    menu.on 'controlPanelToggled', ->
      $scope.showControlPanel = !$scope.showControlPanel
      $scope.$digest()
