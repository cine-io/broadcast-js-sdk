PublishStream = require('../src/publish_stream')
CineIO = require('../src/main')
flashDetect = require('../src/flash_detect')
ajax = require('../src/vendor/ajax')
async = require('async')
ApiBridge = require('../src/api_bridge')

describe 'PublishStream', ->
  unless flashDetect()
    it 'needs to be checked in the browser'
    return

  publishDivNumber = 0
  beforeEach ->
    CineIO.init("MY_PUBLIC_KEY")

  afterEach ->
    CineIO.reset()
    ApiBridge._clear()

  beforeEach ->
    @publishDivID = 'publish-id' + publishDivNumber++
    @publishDiv = document.createElement('div')
    @publishDiv.id = @publishDivID
    document.body.appendChild(@publishDiv)

  afterEach ->
    div = document.getElementById(@publishDivID)
    div.parentNode.removeChild(div)

  beforeEach ->
    nearestServerResponse =
      server:"rtmp://stream.ENDPOINT.cine.io/20C45E/cines"
      code:"lax"
      transcode:"rtmp://publish-ENDPOINT.cine.io/live"

    streamDetailsResponse =
      id:"THE_STREAM_ID"
      name:"my custom name"
      streamName:"streamName"
      play:
        hls:"http://hls.cine.io/cines/streamName/streamName.m3u8"
        rtmp:"rtmp://fml.cine.io/20C45E/cines/streamName?adbe-live-event=streamName"
    @nearestServerCalled = false
    @streamDetailsCalled = false
    jsonpResponder = (options)=>
      if options.url.indexOf("nearest-server") > 0
        @nearestServerCalled = true
        return options.success(nearestServerResponse)
      if options.url.indexOf("/stream") > 0
        @streamDetailsCalled = true
        return options.success(streamDetailsResponse)
      console.log(options)
      throw new Error("UNKNOWN options")

    @xhrStub = sinon.stub(ajax, 'JSONP', jsonpResponder)

  afterEach ->
    @xhrStub.restore()

  checkForPlayer = (done)->
    playerExists = false
    testFunction = -> playerExists
    checkFunction = (callback)=>
      publisherDiv = window.document.getElementById(@publishDivID)
      console.log('checking type', publisherDiv.type)
      playerExists = publisherDiv.type == 'application/x-shockwave-flash'
      setTimeout callback
    async.until testFunction, checkFunction, (err)->
      console.log("GOT ERROR", err)
      done(err)

  describe '.new', ->
    it 'loads the publisher into the div1', (done)->
      domId = @publishDivID
      console.log(@publishDivID)
      streamId = "theStreamId"
      password = "thePassword"
      PublishStream.new streamId, password, domId, (publisher)=>
        checkForPlayer.call(this, done)


  describe '#start', ->
    it 'fetches the stream details and starts the publisher', (done)->
      @timeout 5000
      domId = @publishDivID
      streamId = "theStreamId"
      password = "thePassword"
      publisher = PublishStream.new streamId, password, domId, =>

        publisher.start =>
          checkForPlayer.call this, (err)=>
            expect(err).to.be.undefined
            expect(@nearestServerCalled).to.be.true
            expect(@streamDetailsCalled).to.be.true
            done()

  describe '#stop', ->
    it 'needs to be started', (done)->
      @timeout 10000
      domId = @publishDivID
      streamId = "theStreamId"
      password = "thePassword"
      publisher = PublishStream.new streamId, password, domId, ->
        publisher.stop (err)->
          expect(err.message).to.be.include('Error calling method')
          done()

    it 'stops the publisher', (done)->
      @timeout 10000
      domId = @publishDivID
      streamId = "theStreamId"
      password = "thePassword"
      publisher = PublishStream.new streamId, password, domId, ->
        publisher.start ->
          # we don't have a way yet, to verify that the publisher
          # has successfully started
          # if it hasn't started in 2 seconds, assume failure
          setTimeout(->
            publisher.stop (err)->
              expect(err).to.be.undefined
              done()
          , 2000)
