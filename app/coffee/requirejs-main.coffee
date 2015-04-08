# Set up requirejs
requirejs.config(
  baseUrl: '../'
  paths:
    angular: 'lib/angular.min'
    ace: 'lib/ace'
    'ui-ace': 'lib/ui-ace.min'
    _: 'lib/lodash.min'

  shim:
    _: { exports: '_' }
    angular: { exports: 'angular' }
    'ui-ace':
      deps: ['ace/ace', 'angular']
    'ace/ace': { exports: 'ace' }
)

# The ace plugins assume (when in no-conflict mode) that ace is on window when they are loaded. So we load ace first of all.
req ['ace/ace', 'log'], () ->

  req [
    'angular'
    'app'
    'controllers/margeController'
    'directives/codePanel'
#    'nw/keybindings'
  ], (angular, app) ->
    angular.element(document).ready ->
      angular.bootstrap(document, [app.name])


