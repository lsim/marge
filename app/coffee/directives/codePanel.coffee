define ['app'], (app) ->

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

      $scope.aceLoaded = (editor) ->
        $scope.session = editor.session
    ]
#    link: ($scope, $element, $attrs) ->
