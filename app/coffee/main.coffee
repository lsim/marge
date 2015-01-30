# Set up requirejs
requirejs.config(
  paths:
    angular: 'bower_components/angular/angular.min'
    ace: 'bower_components/ace-builds/src-noconflict/ace'
    'ui-ace': 'bower_components/angular-ui-ace/ui-ace'
    _: 'bower_components/lodash/lodash.min'
    app: 'js/app'

  shim:
    _: { exports: '_' }
    angular: { exports: 'angular' }
    'ui-ace':
      deps: ['ace', 'angular']
)

define ['angular', 'app'], (angular, app) ->
  console.debug "angular loaded", angular?.version

  angular.element(document).ready ->
    angular.bootstrap(document, [app.name])

