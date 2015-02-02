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

  nativeMenubar = new gui.Menu({ type: "menubar" })
  nativeMenubar.createMacBuiltin("Marge", {hideWindow: true}) # TODO: osx specific
  window.menu = nativeMenubar # TODO: osx specific

  menus =
    file: nativeMenubar.items[0].submenu
    edit: nativeMenubar.items[1].submenu

  addMenuItem = (label, handler, menuId, key, modifiers) ->
    menuItem = new gui.MenuItem
      label: label
      click: handler
      key: key
      modifiers: modifiers
    if not menus[menuId]
      console.error "Cannot add menu item #{label} to menu with id #{menuId} because that menu doesn't exist"
    menus[menuId]?.append(menuItem)

  addMenuItem("Refresh+", (-> window.reloadDev()), "file", "r", "cmd-shift") # TODO: osx specific
  addMenuItem("Refresh", (-> window.reload()), "file", "r", "cmd") # TODO: osx specific
  addMenuItem("Debug", (-> window.showDevTools()), "file", "c", "cmd-alt") # TODO: osx specific

  # return
  {registerGlobalShortcutAction, addMenuItem}
