define ['app', 'ace/ace', '_'], (app, ace, _) ->

  Range = ace.require('ace/range').Range

  app.directive 'codePanel', ->
    restrict: 'A'
    scope:
      content: '='
      editorSettings: '='

    template: """
      <div class="code-panel">
        <div class="code-panel-header" title="{{content.path}}">{{content.name}}: {{content.path}}</div>
        <div ui-ace="{onLoad: aceLoaded}" ng-model="content.text" class="ace-component" ></div>
      </div>
    """
    controller: ['$scope', ($scope) ->
      markerIds = []
      updateHighlights = ->
        return unless ($scope.content?.chunks? or $scope.content?.text) and $scope.session?
        _.each markerIds, (markerId) ->
          $scope.session.removeMarker(markerId)
        markerIds = []
        if $scope.content.chunks
          $scope.content.chunks.forEach((chunk) ->
            range = new Range(chunk.lineStart, chunk.colStart, chunk.lineEnd, chunk.colEnd)
            markerIds.push $scope.session.addMarker(range, "marge_highlight_#{chunk.type}", 'text')
          )
#        $scope.session.addGutterDecoration(2, 'marge-conflict-gutter') # Use something like this to place a conflict glyph in the gutter on appropriate lines

      updateMode = ->
        return unless $scope.content? and $scope.session?
        if $scope.content.mode
          $scope.session.setMode
            path: $scope.content.mode

      updateTheme = ->
        return unless $scope.editorSettings?.theme? and $scope.editor?
        $scope.editor.setTheme("ace/theme/#{$scope.editorSettings.theme}", ->
          computedStyle = getComputedStyle($scope.editor.renderer.scroller)
          $scope.$emit "marge:theme-style-change", computedStyle
        )

      $scope.$watch "content.chunks", updateHighlights
#      $scope.$watch "content.text", updateHighlights

      $scope.$watch "content.mode", updateMode

      $scope.$watch "editorSettings.theme", updateTheme

      $scope.aceLoaded = (editor) ->
        $scope.session = editor.session
        $scope.editor = editor
        $scope.editor.renderer.setShowInvisibles(true)
        $scope.editor.setReadOnly(true)
        updateHighlights()
        updateMode()
        updateTheme()
    ]
#    link: ($scope, $element, $attrs) ->
