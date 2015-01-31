define ['app', 'ace/ace', '_'], (app, ace, _) ->

  Range = ace.require('ace/range').Range

  app.directive 'codePanel', ->
    restrict: 'AC'
    scope:
      content: '='

    template: """
        <div ui-ace="{onLoad: aceLoaded}" ng-model="text" class="full-height" />
    """
    controller: ['$scope', ($scope) ->

      $scope.$watch 'content', (newValue) ->
        return unless newValue?
        $scope.text = newValue.text

      $scope.$watch "'' + !!content + !!session", ->
        return unless $scope.content? and $scope.session
        $scope.session.setMode
          path: $scope.content.mode
        _.map($scope.content.highlights, (highlight) -> new Range(highlight.lineStart, highlight.colStart, highlight.lineEnd, highlight.colEnd))
        .forEach((range) -> $scope.session.addMarker(range, 'ace_difference', 'text'))

      $scope.aceLoaded = (editor) ->
        editor.session.doc.foobar = 'barfoo'
        $scope.session = editor.session
    ]
#    link: ($scope, $element, $attrs) ->
