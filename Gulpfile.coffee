

gulp = require 'gulp'
watch = require('gulp-chokidar')(gulp)
coffee = require 'gulp-coffee'
sass = require 'gulp-sass'

gulp.task 'compile-coffee', ->
  gulp.src('./app/coffee/**/*.coffee')
  .pipe(coffee())
  .pipe(gulp.dest('app/js'))

gulp.task 'compile-sass', ->
  gulp.src('./app/scss/**/*.scss')
  .pipe(sass())
  .pipe(gulp.dest('app/css'))

gulp.task 'watch', ['build'], ->
  watch(
    [
      'app/coffee/**/*.coffee'
      'app/scss/**/*.scss'
    ], { root: 'app/coffee' }, 'build')

gulp.task 'build', ['compile-coffee', 'compile-sass'], ->

gulp.task 'default', ['build'], ->