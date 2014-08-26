BASE_URL = "https://www.cine.io/api/1/-"

cachedResponses = {}
hasOwnProperty = Object.prototype.hasOwnProperty

fetchUrlWitCallback = (url, errorMessage, options, callback)->
  if typeof options == 'function'
    callback = options
    options = {}

  options.readFromCache = true unless hasOwnProperty.call(options, 'readFromCache')

  if options.readFromCache && cachedResponses[url]
    # good practice to maintain async consistency
    setTimeout ->
      callback(null, cachedResponses[url])
  else
    ajax
      url: url
      dataType: 'jsonp'
      success: (data, response, xhr)->
        cachedResponses[url] = data
        callback(null, data)
      error: ->
        callback(errorMessage)
  return null

exports.getStreamDetails = (streamId, options, callback)->
  url = "#{BASE_URL}/stream?publicKey=#{Main.config.publicKey}&id=#{streamId}"
  errorMessage = "Could not fetch stream #{streamId}"
  fetchUrlWitCallback(url, errorMessage, options, callback)

exports.nearestServer = (options, callback)->
  url = "#{BASE_URL}/nearest-server?default=ok"
  errorMessage = "Could not fetch nearest server"
  fetchUrlWitCallback(url, errorMessage, options, callback)

exports.getStreamRecordings = (streamId, options, callback)->
  url = "#{BASE_URL}/stream/recordings?publicKey=#{Main.config.publicKey}&id=#{streamId}"
  errorMessage =  "Could not fetch stream recordings for #{streamId}"
  fetchUrlWitCallback(url, errorMessage, options, callback)

exports._clear = ->
  cachedResponses = {}

Main = require('./main')
ajax = require('./vendor/ajax')
