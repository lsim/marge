

gulp = require 'gulp'
watch = require('gulp-watch')
coffee = require 'gulp-coffee'
sass = require 'gulp-sass'

wget = require 'wget'
mkdirp = require 'mkdirp'
path = require 'path'
childProcess = require 'child_process'
rimraf = require 'rimraf'
spawn = require('child_process').spawn

handle = (stream)->
  stream.on 'error', ->
    console.log.apply this, arguments
    stream.end()

gulp.task 'compile-coffee', ->
  gulp.src('./app/coffee/**/*.coffee')
  .pipe(handle(coffee()))
  .pipe(gulp.dest('app/bin'))

gulp.task 'compile-sass', ->
  gulp.src('./app/scss/**/*.scss')
  .pipe(handle(sass()))
  .pipe(gulp.dest('app/bin/css'))

gulp.task 'copy-resources', ->
  gulp.src(['./app/html/**/*.html'])
  .pipe(gulp.dest('app/bin/html'))

gulp.task 'copy-libs', ->
  gulp.src('./app/lib/**')
  .pipe(gulp.dest('app/bin/lib'))

gulp.task 'watch', ['build'], ->
  watch("app/coffee/**/*.coffee", () -> gulp.start('compile-coffee'))
  watch("app/scss/**/*.scss", () -> gulp.start('compile-sass'))
  watch(["app/**/*.html", "!app/bin/**"], () -> gulp.start('copy-resources'))
  watch("app/lib/**", () -> gulp.start('copy-libs'))

gulp.task 'clean', (cb) ->
  rimraf './app/bin', cb

gulp.task 'build', ['compile-coffee', 'compile-sass', 'copy-resources', 'copy-libs'], ->
gulp.task 'default', ['watch'], ->

downloadAtomShell = require 'gulp-download-atom-shell'
gulp.task 'getatomshell', (cb) ->
  downloadAtomShell(
    version: '0.22.3',
    outputDir: 'binaries'
  , cb)

runShellCmd = (cmd, args...) ->
  proc = spawn cmd, args
  proc.stdout.on 'data', (data) -> console.log("#{cmd} stdout: " + data)
  proc.stderr.on 'data', (data) -> console.log("#{cmd} stderr: " + data)
  proc.on 'close', (code) -> console.log "#{cmd} exited with code #{code}"

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
