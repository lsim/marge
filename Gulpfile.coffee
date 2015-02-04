

gulp = require 'gulp'
watch = require('gulp-watch')
coffee = require 'gulp-coffee'
sass = require 'gulp-sass'

wget = require 'wget'
mkdirp = require 'mkdirp'
path = require 'path'
childProcess = require 'child_process'

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

gulp.task 'watch', ['build'], ->
  watch("app/coffee/**/*.coffee", () -> gulp.start('compile-coffee'))
  watch("app/scss/**/*.scss", () -> gulp.start('compile-sass'))

gulp.task 'build', ['compile-coffee', 'compile-sass'], ->
gulp.task 'default', ['watch'], ->

downloadNw = (location, version, urlPlatformName, urlExtension, callback) ->
  filename = "node-webkit-v#{version}-#{urlPlatformName}.#{urlExtension}"
  url = "http://dl.nwjs.io/v#{version}/#{filename}"
  console.log "Creating directory", location
  mkdirp location, (err) ->
    if err then console.error(err) else
      console.log "Downloading from #{url} into #{location}/#{filename}"
      i = 0
      download = wget.download url, "#{location}/#{filename}"
      download.on "error", (err) -> console.error(err)
      download.on "progress", (progress) ->
        if ++i % 100 is 0
          process.stdout.clearLine()
          process.stdout.cursorTo(0)
          process.stdout.write('' + progress)
          #process.stdout.write(new Array((i / 100) % 30).join("."))
      download.on "end", (output) ->
        console.log "Download complete"
        callback?(location, filename)

gulp.task 'getnw', ->
  targetDir = "resources/node-webkit"
  switch process.platform
    when "win32"
      console.error 'Windows is not actively supported'
    when "darwin"
      downloadNw "#{targetDir}", "0.11.6", "osx-x64", "zip", (location, filename) ->
        process.chdir location
        console.log "Unpacking #{process.cwd()}/#{filename}"
        childProcess.exec "unzip #{filename}", (error, stdout, stderr) ->
          console.log "TODO: get the files into the right spot"
    when "linux"
      downloadNw targetDir, "0.10.5", "linux-x64", "tar.gz", (location, filename) ->
        process.chdir location
        console.log "Unpacking #{process.cwd()}/#{filename}"
        childProcess.exec "tar -xzf #{filename} --overwrite", (error, stdout, stderr) ->
          if error then console.error(error, stderr) else
            console.log("Moving #{path.basename(filename, ".tar.gz")} to Linux64")
            childProcess.exec "mv #{path.basename(filename, ".tar.gz")} Linux64"
            console.log("All done. If you get an error when running nw saying something about libudev.so.0, then consider running shellscripts/fix_libudev.so.0_ubuntuproblem.sh")
