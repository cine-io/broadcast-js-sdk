loadingSWF = false
loadedSWF = false
waitingPublishCalls = {}
PUBLISHER_NAME = 'Publisher'
PUBLISHER_URL = '//cdn.cine.io/publisher.swf'
numberOfPublishers = 0

noop = ->

defaultOptions =
  serverURL: null
  streamName: null
  streamKey: null
  audioCodec: 'NellyMoser'
  streamWidth: 720
  streamHeight: 404
  streamFPS: 15
  keyFrameInterval: null
  intervalSecs: 3 #not passed to publisher
  bandwidth: 1500
  videoQuality: 90
  embedTimecode: true
  timecodeFrequency: 1000

loadPublisher = (domNode, publishOptions, publishReadyCallback)->
  swfVersionStr = "11.4.0"
  xiSwfUrlStr = "playerProductInstall.swf"
  flashvars = {}
  params = {}
  attributes = {}
  params.allowscriptaccess = "always"
  params.allowfullscreen = "true"
  params.wmode = 'transparent'
  attributes.id = domNode
  attributes.name = PUBLISHER_NAME
  attributes.align = "middle"
  domWidth = document.getElementById(domNode).offsetWidth
  streamWidth = userOrDefault(publishOptions, 'streamWidth')
  streamHeight = userOrDefault(publishOptions, 'streamHeight')
  height = domWidth / (streamWidth / streamHeight)
  url = "#{window.location.protocol}#{PUBLISHER_URL}"
  swfobject.embedSWF url, domNode, "100%", height, swfVersionStr, xiSwfUrlStr, flashvars, params, attributes, (embedEvent) ->
    if embedEvent.success
      readyCall = ->
        embedEvent.ref.setOptions(jsLogFunction: "_jsLogFunction", jsEmitFunction: publishOptions._emitCallback)
        publisherIsReady(domNode)
      # need to wait a bit until initialization finishes
      setTimeout readyCall, 1000

publisherIsReady = (domNode)->
  # console.log("publisher is ready")
  for call in waitingPublishCalls[domNode]
    call.call()
  delete waitingPublishCalls[domNode]

enqueuePublisherCallback = (domNode, publishOptions, cb)->
  waitingPublishCalls[domNode] ||= []
  waitingPublishCalls[domNode].push ->
    getPublisher domNode, publishOptions, cb

findPublisherInDom = (domNode)->
  node = document.getElementById(domNode)
  return node if node && node.data == (window.location.protocol + PUBLISHER_URL)
  return null

swfObjectCallbackToLoadPublisher = (domNode, publishOptions)->
  return ->
    loadedSWF = true
    loadPublisher(domNode, publishOptions)

publisherIsLoading = (domNode)->
  waitingPublishCalls[domNode]?

# cb(publisher)
# Workflow:
# Case 1: SWFObject not loaded
#   1. Fetch swf object
#   2. load publisher into domNode
#   3. Return publisher to callback
# Case 2: SWFObject is loaded but not in domNode
#   1. load publsiher into domNode
#   2. Return publisher to callback
# Case 3: SWFObject is loaded and publisher in domNode
#   1. Return publisher to callback
# Case 4: Loading has been requested but has not finished
#   1. enqueue callback
getPublisher = (domNode, publishOptions, cb)->
  publisher = findPublisherInDom(domNode)
  # case 3
  return cb(publisher) if publisher
  # case 4
  return enqueuePublisherCallback domNode, publishOptions, cb if publisherIsLoading(domNode)
  # this publisher has not been requested yet
  # case 1,2,3
  enqueuePublisherCallback domNode, publishOptions, cb

  # case 2
  # if swfobject has been loaded, this must be a new publisher, insert the publisher into the dom.
  if loadedSWF
    loadPublisher(domNode, publishOptions)
  # case 1
  # else load the swf
  else
    getScript urlWithProtocol('ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js'), swfObjectCallbackToLoadPublisher(domNode, publishOptions, cb)

generateStreamName = (stream, password)->
  "#{stream.streamName}?#{password}"


userOrDefault = (userOptions, key)->
  if Object.prototype.hasOwnProperty.call(userOptions, key) then userOptions[key] else defaultOptions[key]

class Publisher
  constructor: (@streamId, @password, @domNode, @publishOptions={}, callback=noop)->
    if typeof @publishOptions == 'function'
      callback = publishOptions
      @publishOptions = {}
    @_ensureLoaded(callback)
    numberOfPublishers+=1

    @publishOptions._emitCallback = createGlobalCallback(this)

  start: (callback=noop)->
    @_ensureLoaded (publisher)=>
      console.log('fetching stream', publisher)
      ApiBridge.getStreamDetails @streamId, (err, stream)=>
        return callback(err) if err
        options = @_options(stream)
        # console.log('streamingggg!!', options)
        # console.log("SET OPTIONS", publisher.setOptions)
        publisher.setOptions options
        publisher.start()
        callback()

  stop: (callback=noop)->
    @_ensureLoaded (publisher)->
      try
        publisher.stop()
      catch e
        return callback(e)
      callback()

  preview: (callback=noop)->
    @_ensureLoaded (publisher)->
      try
        publisher.preview()
      catch e
        return callback(e)
      callback()

  getMediaInfo: (callback=noop)->
    @_ensureLoaded (publisher)->
      response = null
      try
        response = publisher.getMediaInfo()
      catch e
        return callback(e)
      callback(null, response)

  sendData: (data, callback=noop)->
    @_ensureLoaded (publisher)->
      response = null
      try
        response = publisher.sendData(data)
      catch e
        return callback(e)
      callback(null, response)

  selectMicrophone: (callback=noop)->
    @_ensureLoaded (publisher)->
      response = null
      try
        response = publisher.selectMicrophone()
      catch e
        return callback(e)
      callback(null, response)

  selectCamera: (callback=noop)->
    @_ensureLoaded (publisher)->
      response = null
      try
        response = publisher.selectCamera()
      catch e
        return callback(e)
      callback(null, response)

  _options: (stream)->
    options =
      serverURL: @serverURL || ApiBridge.defaultBaseUrl()
      streamName: generateStreamName(stream, @password)
      audioCodec: userOrDefault(@publishOptions, 'audioCodec')
      streamWidth: userOrDefault(@publishOptions, 'streamWidth')
      streamHeight: userOrDefault(@publishOptions, 'streamHeight')
      streamFPS: userOrDefault(@publishOptions, 'streamFPS')
      bandwidth: userOrDefault(@publishOptions, 'bandwidth') * 1024 * 8
      videoQuality: userOrDefault(@publishOptions, 'videoQuality')
      embedTimecode: userOrDefault(this.publishOptions, "embedTimecode"),
      timecodeFrequency: userOrDefault(this.publishOptions, "timecodeFrequency")
    intervalSecs = userOrDefault(@publishOptions, 'intervalSecs')
    options.keyFrameInterval = options.streamFPS * intervalSecs
    options

  _eventHandler: (event)=>
    if typeof @publishOptions.eventHandler == 'function'
      @publishOptions.eventHandler(event)

  _ensureLoaded: (cb=noop)->
    ApiBridge.nearestServer (err, data)=>
      @serverUrl = data.transcode
      getPublisher @domNode, @publishOptions, cb

exports.new = (streamId, password, domNode, publishOptions={}, callback=noop)->
  new Publisher(streamId, password, domNode, publishOptions, callback)

createGlobalCallback = (object)->
  functionName = "_publisherEmit#{numberOfPublishers}"
  window[functionName] = object._eventHandler
  return functionName

window._jsLogFunction = (msg)->
  console.log('_jsLogFunction', msg)

getScript = require('./vendor/get_script')
ApiBridge = require('./api_bridge')
urlWithProtocol = require('./url_with_protocol')
