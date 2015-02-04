define ['gui'], (gui) ->

  window = gui.Window.get()

  registerGlobalShortcutAction = (key, name, handler) ->
    shortcut = new gui.Shortcut
      key: key
      active: handler
      failed: (msg) -> console.debug "Failed registering #{name}", msg
    gui.App.registerGlobalHotKey(shortcut)

#  registerGlobalShortcutAction "Ctrl+r", "Reload", gui.Window.get().reloadDev
#  registerGlobalShortcutAction "Ctrl+Shift+r", "Reload (no cache)", gui.Window.get().reloadIgnoringCache

  menus = {}
  if window.menu
    console.debug "There was already a menu with #menuitems", window.menu.items.length
    nativeMenubar = window.menu
    while nativeMenubar.items.length
      nativeMenubar.removeAt(0)
  else
    console.debug "There was no menu - creating one"
    nativeMenubar = new gui.Menu({ type: "menubar" })

  if process.platform is 'darwin'
    nativeMenubar.createMacBuiltin("Marge", {hideWindow: true})
    menus =
      file: nativeMenubar.items[0].submenu
      edit: nativeMenubar.items[1].submenu
  else
    menus =
      file: new gui.Menu()
      edit: new gui.Menu()
    fileMenuItem = new gui.MenuItem({label: "File", submenu: menus.file})
    editMenuItem = new gui.MenuItem({label: "Edit", submenu: menus.edit})

    nativeMenubar.append(fileMenuItem)
    nativeMenubar.append(editMenuItem)

  window.menu = nativeMenubar

  addMenuItem = (label, handler, menuId, key, modifiers) ->
    menuItem = new gui.MenuItem
      label: label
      click: handler
      key: key
      modifiers: modifiers
    if menus?[menuId]
      menus?[menuId]?.append(menuItem)
    else
      console.error "Cannot add menu item #{label} to menu with id #{menuId} because that menu doesn't exist"

  platformModifier = if process.platform is "darwin" then "cmd" else "ctrl"

  addMenuItem("Refresh+", (-> window.reloadDev()), "file", "r", "#{platformModifier}-shift")
  addMenuItem("Refresh", (-> window.reload()), "file", "r", "#{platformModifier}")
  addMenuItem("Debug", (-> window.showDevTools()), "file", "c", "#{platformModifier}-alt")

  # return
  {
    registerGlobalShortcutAction
    addMenuItem
    getPlatformModifer: () -> platformModifier
  }

