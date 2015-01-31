define ['app', 'ace/ace', '_'], (app, ace, _) ->

  Range = ace.require('ace/range').Range

  app.directive 'codePanel', ->
    restrict: 'AC'
    scope:
      content: '='

    template: """
        <div ui-ace="{onLoad: aceLoaded}" ng-model="content.text" class="full-height" />
    """
    controller: ['$scope', ($scope) ->

      updateHighlights = ->
        return unless $scope.content?.highlights? and $scope.session?
        if $scope.markerIds
          _.each $scope.markerIds, (markerId) ->
            $scope.session.removeMarker(markerId)
        $scope.markerIds = []
        $scope.content.highlights.forEach((highlight) ->
          range = new Range(highlight.lineStart, highlight.colStart, highlight.lineEnd, highlight.colEnd)
          $scope.markerIds.push $scope.session.addMarker(range, 'ace_difference', 'text'))

      updateMode = ->
        return unless $scope.content?.highlights? and $scope.session?
        $scope.session.setMode
          path: $scope.content.mode

      $scope.$watch "content.highlights", updateHighlights

      $scope.$watch "content.mode", updateMode

      $scope.aceLoaded = (editor) ->
        $scope.session = editor.session
        updateHighlights()
        updateMode()
    ]
#    link: ($scope, $element, $attrs) ->
