define [], ->

  remote = require 'remote'
  Menu = remote.require 'menu'
  BrowserWindow = remote.require 'browser-window'
  #  MenuItem = remote.require 'menu-item'
  app = remote.require 'app'

  template = [
    {
      label: 'Atom Shell',
      submenu: [
        {
          label: 'About Marge',
          selector: 'orderFrontStandardAboutPanel:'
        },
        {
          type: 'separator'
        },
        {
          label: 'Services',
          submenu: []
        },
        {
          type: 'separator'
        },
        {
          label: 'Hide Marge',
          accelerator: 'Command+H',
          selector: 'hide:'
        },
        {
          label: 'Hide Others',
          accelerator: 'Command+Shift+H',
          selector: 'hideOtherApplications:'
        },
        {
          label: 'Show All',
          selector: 'unhideAllApplications:'
        },
        {
          type: 'separator'
        },
        {
          label: 'Quit',
          accelerator: 'Command+Q',
          click: () -> app.quit()
        },
      ]
    },
    {
      label: 'Edit',
      submenu: [
        {
          label: 'Undo',
          accelerator: 'Command+Z',
          selector: 'undo:'
        },
        {
          label: 'Redo',
          accelerator: 'Shift+Command+Z',
          selector: 'redo:'
        },
        {
          type: 'separator'
        },
        {
          label: 'Cut',
          accelerator: 'Command+X',
          selector: 'cut:'
        },
        {
          label: 'Copy',
          accelerator: 'Command+C',
          selector: 'copy:'
        },
        {
          label: 'Paste',
          accelerator: 'Command+V',
          selector: 'paste:'
        },
        {
          label: 'Select All',
          accelerator: 'Command+A',
          selector: 'selectAll:'
        },
      ]
    },
    {
      label: 'View',
      submenu: [
        {
          label: 'Reload',
          accelerator: 'Command+R',
          click: () -> BrowserWindow.getFocusedWindow().reloadIgnoringCache()
        },
        {
          label: 'Toggle DevTools',
          accelerator: 'Alt+Command+I',
          click: () -> BrowserWindow.getFocusedWindow().toggleDevTools()
        },
        {
          label: 'Toggle Controls',
          accelerator: 'Alt+Command+C',
          click: () -> eventEmitter.emit 'controlPanelToggled'
        }
      ]
    },
    {
      label: 'Window',
      submenu: [
        {
          label: 'Minimize',
          accelerator: 'Command+M',
          selector: 'performMiniaturize:'
        },
        {
          label: 'Close',
          accelerator: 'Command+W',
          selector: 'performClose:'
        },
        {
          type: 'separator'
        },
        {
          label: 'Bring All to Front',
          selector: 'arrangeInFront:'
        },
      ]
    },
    {
      label: 'Help',
      submenu: []
    },
  ]

  menu = Menu.buildFromTemplate(template)

  Menu.setApplicationMenu(menu)

  EventEmitter = require('events').EventEmitter
  eventEmitter = new EventEmitter()
  # return
  eventEmitter
