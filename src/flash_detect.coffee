newNavigator = null

getNavigator = ->
  newNavigator || navigator

module.exports = ->
  try
    return true if new ActiveXObject("ShockwaveFlash.ShockwaveFlash")
  catch e
    return false if typeof getNavigator() is 'undefined'
    return false unless getNavigator().mimeTypes
    return false if getNavigator().mimeTypes["application/x-shockwave-flash"] is undefined
    return true if getNavigator().mimeTypes["application/x-shockwave-flash"].enabledPlugin
  false

module.exports._injectNavigator = (nav)->
  newNavigator = nav
