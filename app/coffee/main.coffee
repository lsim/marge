# Set up requirejs
requirejs.config(
  baseUrl: 'js'
  paths:
    angular: '../lib/angular.min'
    ace: '../lib/ace'
    'ui-ace': '../lib/ui-ace.min'
    _: '../lib/lodash.min'

  shim:
    _: { exports: '_' }
    angular: { exports: 'angular' }
    'ui-ace':
      deps: ['ace', 'angular']
)

define [
  'angular'
  'app'
  'controllers/margeController'
], (angular, app) ->
  console.log "angular loaded", angular?.version

  angular.element(document).ready ->
    $injector = angular.bootstrap(document, [app.name])


