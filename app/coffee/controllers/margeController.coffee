define ['app', 'gui'], (app, gui) ->
  app.controller 'margeController', ($scope) ->
    $scope.text = gui.App.argv[0]