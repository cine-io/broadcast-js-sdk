publisherReady = false
loadingSWF = false
loadedSWF = false
waitingPublishCalls = {}
BASE_URL = 'rtmp://publish.west.cine.io/live'
PUBLISHER_NAME = 'Publisher'
PUBLISHER_URL = '//cdn.cine.io/publisher.swf'
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
  intervalSecs: 10 #not passed to publisher
  bandwidth: 1500
  videoQuality: 90

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
  streamWidth = publishOptions.streamWidth || defaultOptions.streamWidth
  streamHeight = publishOptions.streamHeight || defaultOptions.streamHeight
  height = domWidth / (streamWidth / streamHeight)
  url = "#{window.location.protocol}#{PUBLISHER_URL}"
  swfobject.embedSWF url, domNode, "100%", height, swfVersionStr, xiSwfUrlStr, flashvars, params, attributes, (embedEvent) ->
    if embedEvent.success
      readyCall = ->
        embedEvent.ref.setOptions(jsLogFunction: "_jsLogFunction", jsEmitFunction: "_publisherEmit")
        publisherIsReady(domNode)
      # need to wait a bit until initialization finishes
      setTimeout readyCall, 1000

publisherIsReady = (domNode)->
  console.log('publisher is ready!!!')
  publisherReady = true
  for call in waitingPublishCalls[domNode]
    call.call()
  delete waitingPublishCalls[domNode]

enqueuePublisherCallback = (domNode, publishOptions, cb)->
  waitingPublishCalls[domNode] ||= []
  waitingPublishCalls[domNode].push ->
    console.log("HERE I AM")
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
    getScript '//ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js', swfObjectCallbackToLoadPublisher(domNode, publishOptions, cb)

generateStreamName = (stream, password)->
  "#{stream.streamName}?#{password}&adbe-live-event=#{stream.streamName}"

class Publisher
  constructor: (@streamId, @password, @domNode, @publishOptions)->
    @_ensureLoaded()

  start: ->
    console.log('loading publisher')
    @_ensureLoaded (publisher)=>
      console.log('fetching stream', publisher)
      ApiBridge.getStreamDetails @streamId, (err, stream)=>
        options = @_options(stream)
        console.log('streamingggg!!', options)
        publisher.setOptions options
        publisher.start()

  stop: ->
    @_ensureLoaded (publisher)->
      publisher.stop()

  _options: (stream)->
    options =
      serverURL: BASE_URL
      streamName: generateStreamName(stream, @password)
      audioCodec: @publishOptions.audioCodec || defaultOptions.audioCodec
      streamWidth: @publishOptions.streamWidth || defaultOptions.streamWidth
      streamHeight: @publishOptions.streamHeight || defaultOptions.streamHeight
      streamFPS: @publishOptions.streamFPS || defaultOptions.streamFPS
      bandwidth: @publishOptions.bandwidth || defaultOptions.bandwidth * 1024 * 8
      videoQuality: @publishOptions.videoQuality || defaultOptions.videoQuality
    intervalSecs = @publishOptions.intervalSecs || defaultOptions.intervalSecs
    options.keyFrameInterval = options.streamFPS * intervalSecs
    options

  _ensureLoaded: (cb=noop)->
    getPublisher @domNode, @publishOptions, cb

exports.new = (streamId, password, domNode, publishOptions)->
  new Publisher(streamId, password, domNode, publishOptions)

window._publisherEmit = (eventName, stuff...)->
  switch(eventName)
    when "connect", "disconnect", "publish", "status", "error"
      console.log(stuff...)
    else
      console.log(stuff...)


window._jsLogFunction = (msg)->
  console.log('_jsLogFunction', msg)

getScript = require('./get_script')
ApiBridge = require('./api_bridge')
