

gulp = require 'gulp'
watch = require('gulp-chokidar')(gulp)
coffee = require 'gulp-coffee'

gulp.task 'compile-coffee', ->
  gulp.src('./app/coffee/**/*.coffee')
  .pipe(coffee())
  .pipe(gulp.dest('app/js'))

gulp.task 'watch', ->
  watch(
    [
      'app/coffee/**/*.coffee'
    ], { root: 'app/coffee' }, 'build')

gulp.task 'build', ['compile-coffee'], ->

gulp.task 'default', ['build'], ->