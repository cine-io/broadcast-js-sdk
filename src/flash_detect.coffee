module.exports = ->
  try
    return true if new ActiveXObject("ShockwaveFlash.ShockwaveFlash")
  catch e
    return false if typeof navigator is 'undefined'
    return false unless navigator.mimeTypes
    return false if navigator.mimeTypes["application/x-shockwave-flash"] is undefined
    return true if navigator.mimeTypes["application/x-shockwave-flash"].enabledPlugin
  false
