requiresInit = ->
  throw new Error("CineIO.init(CINE_IO_PUBLIC_KEY) has not been called.") unless CineIO.config.publicKey

CineIO =
  version: "0.1.2"
  config: {}
  init: (publicKey, options)->
    throw new Error("Public Key required") unless publicKey
    CineIO.config.publicKey = publicKey
    for prop, value of options
      CineIO.config[prop] = value

  reset: ->
    CineIO.config = {}

  publish: (streamId, password, domNode, publishOptions={})->
    requiresInit()
    throw new Error("Stream ID required.") unless streamId
    throw new Error("Password required.") unless password
    throw new Error("DOM node required.") unless domNode
    PublishStream.new(streamId, password, domNode, publishOptions)

  play: (streamId, domNode, playOptions={}, callback)->
    requiresInit()
    throw new Error("Stream ID required.") unless streamId
    throw new Error("DOM node required.") unless domNode
    PlayStream.live(streamId, domNode, playOptions, callback)

  playRecording: (streamId, recordingName, domNode, playOptions={}, callback)->
    requiresInit()
    throw new Error("Stream ID required.") unless streamId
    throw new Error("Recording name required.") unless recordingName
    throw new Error("DOM node required.") unless domNode
    PlayStream.recording(streamId, recordingName, domNode, playOptions, callback)

  getStreamDetails: (streamId, callback)->
    requiresInit()
    throw new Error("Stream ID required.") unless streamId
    ApiBridge.getStreamDetails(streamId, callback)

  getStreamRecordings: (streamId, options, callback)->
    requiresInit()
    throw new Error("Stream ID required.") unless streamId
    ApiBridge.getStreamRecordings(streamId, options, callback)

window.CineIO = CineIO if typeof window isnt 'undefined'

module.exports = CineIO

PlayStream = require('./play_stream')
PublishStream = require('./publish_stream')
ApiBridge = require('./api_bridge')
