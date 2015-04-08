
app = require 'app'  # Module to control application life.
BrowserWindow = require 'browser-window'  # Module to create native browser window.

# Report crashes to our server.
#require('crash-reporter').start()

# Keep a global reference of the window object, if you don't, the window will
# be closed automatically when the javascript object is GCed.
mainWindow = null

# Quit when all windows are closed.
app.on 'window-all-closed', () ->
  if process.platform isnt 'darwin'
    app.quit()
console.log "node version: #{process.version}, atom shell version: #{process.versions['atom-shell']}"
# This method will be called when atom-shell has done everything
# initialization and ready for creating browser windows.
app.on 'ready', () ->
  # Create the browser window.
  mainWindow = new BrowserWindow({width: 800, height: 600})

  # and load the index.html of the app.
  indexPath = "file://#{__dirname}/html/index.html"
  mainWindow.loadUrl(indexPath)

  # Emitted when the window is closed.
  mainWindow.on 'closed', () ->
    # Dereference the window object, usually you would store windows
    # in an array if your app supports multi windows, this is the time
    # when you should delete the corresponding element.
    mainWindow = null
