BASE_URL = "https://www.cine.io/api/1/-"

cachedResponses = {}

fetchUrlWitCallback = (url, errorMessage, callback)->
  if cachedResponses[url]
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

exports.getStreamDetails = (streamId, callback)->
  url = "#{BASE_URL}/stream?publicKey=#{Main.config.publicKey}&id=#{streamId}"
  errorMessage = "Could not fetch stream #{streamId}"
  fetchUrlWitCallback(url, errorMessage, callback)

exports.getStreamRecordings = (streamId, callback)->
  url = "#{BASE_URL}/stream/recordings?publicKey=#{Main.config.publicKey}&id=#{streamId}"
  errorMessage =  "Could not fetch stream recordings for #{streamId}"
  fetchUrlWitCallback(url, errorMessage, callback)

Main = require('./main')
ajax = require('./vendor/ajax')
