

gulp = require 'gulp'
watch = require('gulp-chokidar')(gulp)
coffee = require 'gulp-coffee'
sass = require 'gulp-sass'

handle = (stream)->
  stream.on 'error', ->
    console.log.apply this, arguments
    stream.end()

gulp.task 'compile-coffee', ->
  gulp.src('./app/coffee/**/*.coffee')
  .pipe(handle(coffee()))
  .pipe(gulp.dest('app/js'))

gulp.task 'compile-sass', ->
  gulp.src('./app/scss/**/*.scss')
  .pipe(handle(sass()))
  .pipe(gulp.dest('app/css'))

gulp.task 'coffee-watch', ['compile-coffee'], ->
  watch([], { root: 'app/coffee' }, 'compile-coffee')

gulp.task 'scss-watch', ['compile-sass'], ->
  watch([], { root: 'app/scss' }, 'compile-sass')

gulp.task 'watch', ['coffee-watch', 'scss-watch'], ->

gulp.task 'build', ['compile-coffee', 'compile-sass'], ->
gulp.task 'default', ['watch'], ->


