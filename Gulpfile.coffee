gulp = require 'gulp'
watch = require 'gulp-watch'
coffee = require 'gulp-coffee'
sass = require 'gulp-sass'
gutil = require 'gulp-util'

wget = require 'wget'
mkdirp = require 'mkdirp'
path = require 'path'
childProcess = require 'child_process'
rimraf = require 'rimraf'
spawn = require('child_process').spawn

handle = (stream)->
  stream.on 'error', (args...) ->
    gutil.log(args...)
    stream.end()

compileCoffee = ->
  trace "building coffee..",
    gulp.src('./app/coffee/**/*.coffee')
    .pipe(handle(coffee()))
    .pipe(gulp.dest('app/bin'))
#gulp.task 'compile-coffee', compileCoffee

compileSass = ->
  trace "building scss..",
    gulp.src('./app/scss/**/*.scss')
    .pipe(handle(sass()))
    .pipe(gulp.dest('app/bin/css'))
#gulp.task 'compile-sass', compileSass

copyResources = ->
  trace "copying resources..",
    gulp.src(['./app/html/**/*.html'])
    .pipe(gulp.dest('app/bin/html'))
#gulp.task 'copy-resources', copyResources

copyLibs = ->
  trace "copying libs..",
    gulp.src('./app/lib/**')
    .pipe(gulp.dest('app/bin/lib'))
#gulp.task 'copy-libs', copyLibs

trace = (taskName, stream) ->
  gutil.log "started #{taskName}"
  stream.on 'end', ->
    gutil.log "Finished #{taskName}"
  stream.on 'error', (err) ->
    gutil.log "Error #{taskName}: #{err}"
  # return
  stream

merge = require('merge-stream')
doBuild = ->
  trace("doing full build",
    merge(
      compileCoffee(),
      compileSass(),
      copyResources(),
      copyLibs()
    )
  )

gulp.task 'watch', ['build'], ->
  createEventLogger = (callback) ->
    (event) ->
      gutil.log("Watcher: #{event.path} #{event.event}!")
      if event.event is 'unlink' # on delete, we do a clean + build of everything
        cleanBinFolder(->
          doBuild()
        )
      else
        callback(event)

  watch("app/coffee/**/*.coffee", createEventLogger(compileCoffee))
  watch("app/scss/**/*.scss", createEventLogger(compileSass))
  watch(["app/html/**/*.html"], createEventLogger(copyResources))
  watch("app/lib/**", () -> createEventLogger(copyLibs))

cleanBinFolder = (cb) ->
  rimraf('./app/bin', cb)

gulp.task 'clean', (cb) -> cleanBinFolder(cb)
gulp.task 'build', doBuild
gulp.task 'default', ['watch'], ->

downloadAtomShell = require 'gulp-download-atom-shell'
gulp.task 'getatomshell', (cb) ->
  downloadAtomShell(
    version: '0.22.3',
    outputDir: 'binaries'
  , cb)

runShellCmd = (cmd, args...) ->
  proc = spawn cmd, args
  proc.stdout.on 'data', (data) -> gutil.log("#{cmd} stdout: " + data)
  proc.stderr.on 'data', (data) -> gutil.log("#{cmd} stderr: " + data)
  proc.on 'close', (code) -> gutil.log "#{cmd} exited with code #{code}"

gulp.task 'demo-mac', ['build'], ->
  runShellCmd 'binaries/Atom.app/Contents/MacOS/Atom', 'app', 'corpus/original.coffee', 'corpus/future1.coffee', 'corpus/future2.coffee'

#
# Dist related tasks
#

gulp.task 'clean-dist', (cb) ->
  rimraf('dist/**', cb)

atomshell = require('gulp-atom-shell')
gulp.task 'dist-mac', ['build','clean-dist'], ->
  gulp.src(['app/**', '!app/{coffee,scss,lib,html,bower_components}' ])
  .pipe(handle(atomshell(
      version: '0.22.3'
      platform: 'darwin'
    )))
  .pipe(handle(atomshell.zfsdest('dist/app.zip')))

gulp.task 'unpack-mac-dist', ['dist-mac'], ->
  runShellCmd "open", "-W", "dist/app.zip" # All the sane ways of doing this that I have tried resulted in corrupted runtime :/

gulp.task 'demo-mac-dist', ->
  runShellCmd 'open', '-W', 'dist/app/marge.app', '--args', 'corpus/original.coffee', 'corpus/future1.coffee', 'corpus/future2.coffee'
