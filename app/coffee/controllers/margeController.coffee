define ['app', 'gui', '_',
        'services/file',
        'services/diff',
        'services/aceMode',
        'services/highlight'
], (app, gui, _) ->
  minimist = require('minimist')

  # This is the outermost controller of the application. It parses command line arguments etc

  app.controller 'margeController', ($scope, filesvc, diffsvc, aceModesvc, highlightsvc) ->

    $scope.editorSettings =
      theme: "monokai"

    argv = minimist(gui.App.argv)
    if argv._.length >= 3
      filePaths = _.takeRight(argv._, 3) # Take the last three arguments
      loadPath = (panelName, path) ->
        filesvc(path).then((contents) ->
          $scope[panelName + 'Content'] =
            text: contents
            mode: aceModesvc(path)
            title: "#{panelName}: #{path}"
        , (err) -> console.error "Failed loading file", err)
      loadPath('base', filePaths[0])
      loadPath('v1', filePaths[1])
      loadPath('v2', filePaths[2])
    else
      $scope.baseContent =
        text: "invoke with three file paths (base, v1, v2) as arguments" # Find better way of displaying this
        title: "Error"
    $scope.matchThresholdString = diffsvc.dmp.Match_Threshold
    $scope.patchV1 = true

    ###
      3-way merge pseudocode:
      patches = patch_make(V0, V2)
      (V3, result) = patch_apply(patches, V1)

      The result list is an array of true/false values.  If it's all true,
      then the merge worked great.  If there's a false, then one of the
      patches could not be applied.  In that case it might be worth swapping
      V1 and V2, trying again and seeing if the results are better.

    ###
    threeWayMerge = (v0, v1, v2) ->
      dmp = diffsvc.dmp
      # character level merge
#      patches = dmp.patch_make(v0, v2) # character
#      [resultText, status] = dmp.patch_apply(patches, v1)
#      console.debug "3way", resultText, status, patches
#      return [resultText, status]

      # line level merge
      console.debug "diff_linesToChars_1", a = dmp.diff_linesToChars_(v0, v2)
      console.debug "diff_linesToChars_2", diffs = dmp.diff_main(a.chars1, a.chars2, false)
#      console.debug "diff_linesToChars_3", dmp.diff_charsToLines_(diffs, a.lineArray), diffs

      console.debug "line_mode_patch", line_patches = dmp.patch_make(a.chars2, diffs)
      console.debug "line_mode_merge"
      [resultText, status] = dmp.patch_apply(line_patches, v1)
      [resultText, status]

    updateDiffs = _.debounce( ->
      return unless $scope.baseContent? and $scope.v1Content? and $scope.v2Content?
      differences = diffsvc.diff($scope.baseContent.text, $scope.v1Content.text)

#      $scope.baseContent.highlights = highlightsvc(differences, -1)
      $scope.v1Content.highlights = highlightsvc(differences, 1)

      differences = diffsvc.diff($scope.baseContent.text, $scope.v2Content.text)
      $scope.v2Content.highlights = highlightsvc(differences, 1)
      $scope.$apply()
    , 20)

    #TODO: get rid of this since those panels will be read only - or make it a configuration option to have them editable
    $scope.$watch "baseContent.text + v1Content.text + v2Content.text", ->
      updateDiffs()
      updateThreewayMerge()

    updateThreewayMerge = _.debounce(->
      return unless $scope.matchThresholdString? and $scope.patchV1? and $scope.baseContent? and $scope.v1Content? and $scope.v2Content?
      matchThreshold = parseFloat($scope.matchThresholdString)
      diffsvc.dmp.Match_Threshold = matchThreshold
      patchV1 = $scope.patchV1
      if patchV1
        [merged, result] = threeWayMerge($scope.baseContent.text, $scope.v1Content.text, $scope.v2Content.text)
      else
        [merged, result] = threeWayMerge($scope.baseContent.text, $scope.v2Content.text, $scope.v1Content.text)
      $scope.resultContent =
        text: merged
        mode: $scope.v1Content.mode
        title: "Result #{matchThreshold}|#{if patchV1 then "v2->v1" else "v1->v2"}|#{result.join(",")}"
      $scope.$apply()
    , 20)

    $scope.$watch 'matchThresholdString', ->
      updateThreewayMerge()
      updateDiffs()

    $scope.$watch 'patchV1', ->
      updateThreewayMerge()
      updateDiffs()
