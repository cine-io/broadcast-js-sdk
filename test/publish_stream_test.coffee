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
  @timeout 10000

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
        rtmp:"rtmp://fml.cine.io/20C45E/cines/streamName"
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
      console.log("GOT ERROR", err) if err
      done(err)

  describe '.new', ->
    it 'loads the publisher into the div1', (done)->
      domId = @publishDivID
      console.log(@publishDivID)
      streamId = "theStreamId"
      password = "thePassword"
      PublishStream.new streamId, password, domId, (publisher)=>
        checkForPlayer.call(this, done)


  describe 'eventHandler option', ->
    it 'calls back to the eventHandler on publisher events', (done)->
      domId = @publishDivID
      streamId = "theStreamId"
      password = "thePassword"
      eventCalled = false
      options =
        eventHandler: (event)->
          eventCalled = true

      publisher = PublishStream.new streamId, password, domId, options, =>

        publisher.start =>
          checkForPlayer.call this, (err)=>
            expect(err).to.be.undefined
            expect(@nearestServerCalled).to.be.true
            expect(@streamDetailsCalled).to.be.true

            testFunction = -> eventCalled
            checkFunction = setTimeout
            async.until testFunction, checkFunction, done

  describe '#preview', ->
    it 'previews the publisher', (done)->
      domId = @publishDivID
      streamId = "theStreamId"
      password = "thePassword"
      publisher = PublishStream.new streamId, password, domId, =>

        publisher.preview (err, response)=>
          expect(err).to.be.undefined
          checkForPlayer.call this, (err)=>
            expect(err).to.be.undefined
            expect(@nearestServerCalled).to.be.true
            expect(@streamDetailsCalled).to.be.true
            done()

  describe '#getMediaInfo', ->
    it 'fetches the media details', (done)->
      domId = @publishDivID
      streamId = "theStreamId"
      password = "thePassword"
      publisher = PublishStream.new streamId, password, domId, =>

        publisher.getMediaInfo (err, response)=>
          expect(err).to.be.null
          expect(response['cameras']).to.have.length.of.at.least(1)
          expect(response['microphones']).to.have.length.of.at.least(1)
          checkForPlayer.call this, (err)=>
            expect(err).to.be.undefined
            expect(@nearestServerCalled).to.be.true
            expect(@streamDetailsCalled).to.be.false
            done()

  describe '#selectMicrophone', ->
    it 'shows the microphone selector', (done)->
      domId = @publishDivID
      streamId = "theStreamId"
      password = "thePassword"
      publisher = PublishStream.new streamId, password, domId, =>

        publisher.selectMicrophone (err)=>
          expect(err).to.be.null
          checkForPlayer.call this, (err)=>
            expect(err).to.be.undefined
            expect(@nearestServerCalled).to.be.true
            expect(@streamDetailsCalled).to.be.false
            done()

  describe '#selectCamera', ->
    it 'shows the microphone selector', (done)->
      domId = @publishDivID
      streamId = "theStreamId"
      password = "thePassword"
      publisher = PublishStream.new streamId, password, domId, =>

        publisher.selectCamera (err)=>
          expect(err).to.be.null
          checkForPlayer.call this, (err)=>
            expect(err).to.be.undefined
            expect(@nearestServerCalled).to.be.true
            expect(@streamDetailsCalled).to.be.false
            done()

  describe '#start', ->
    it 'fetches the stream details and starts the publisher', (done)->
      domId = @publishDivID
      streamId = "theStreamId"
      password = "thePassword"
      publisher = PublishStream.new streamId, password, domId, =>

        publisher.start (err)=>
          expect(err).to.be.undefined
          checkForPlayer.call this, (err)=>
            expect(err).to.be.undefined
            expect(@nearestServerCalled).to.be.true
            expect(@streamDetailsCalled).to.be.true
            done()

  describe '#sendData', ->
    it 'needs to be started', (done)->
      domId = @publishDivID
      streamId = "theStreamId"
      password = "thePassword"
      publisher = PublishStream.new streamId, password, domId, ->
        publisher.sendData some: "data", (err, response)->
          expect(err).to.be.null
          expect(response).to.be.false
          done()

    it 'sends data over the data channel', (done)->
      domId = @publishDivID
      streamId = "theStreamId"
      password = "thePassword"
      publisher = PublishStream.new streamId, password, domId, ->
        publisher.start ->
          # we don't have a way yet, to verify that the publisher
          # has successfully started
          # if it hasn't started in 2 seconds, assume failure
          setTimeout(->
            publisher.sendData some: "data", (err, response)->
              expect(err).to.be.null
              expect(response).to.be.true
              done()
          , 2000)

  describe '#stop', ->
    it 'stops the publisher', (done)->
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

  describe '_options', ->
    createPublisher = (streamId, options, done)->
      domId = @publishDivID
      console.log(@publishDivID, options)
      password = "thePassword"
      PublishStream.new streamId, password, domId, options, =>
        checkForPlayer.call(this, done)

    checkForOptions = (givenOptions, expectedOptions, done)->
      streamId = "theStreamId"
      publisher = createPublisher.call this, streamId, givenOptions, (err)=>
        expect(err).to.be.undefined
        ApiBridge.getStreamDetails streamId, (err, stream)=>
          expect(err).to.be.null
          actualOptions = publisher._options(stream)
          console.log("actual", actualOptions)
          console.log("expected", expectedOptions)
          expect(actualOptions).to.deep.equal(expectedOptions)
          checkForPlayer.call(this, done)

    it 'generates the correct default options', (done)->
      expectedOptions =
        audioCodec: "NellyMoser"
        bandwidth: 1500 * 1024
        keyFrameInterval: 45
        serverURL: "rtmp://publish-sfo1.cine.io:1936/live"
        streamFPS: 15
        streamHeight: 404
        streamName: "streamName?thePassword"
        streamWidth: 720
        videoQuality: 0
        embedTimecode: true
        timecodeFrequency: 1000
        favorArea: false
      givenOptions = {}
      checkForOptions.call this, givenOptions, expectedOptions, done

    it 'can overwrite default options', (done)->
      expectedOptions =
        audioCodec: "Speex"
        bandwidth: 2500 * 1024
        keyFrameInterval: 80
        serverURL: "rtmp://publish-sfo1.cine.io:1936/live"
        streamFPS: 20
        streamHeight: 900
        streamName: "streamName?thePassword"
        streamWidth: 1600
        videoQuality: 70
        embedTimecode: false
        timecodeFrequency: 999
        favorArea: true

      givenOptions =
        audioCodec: 'Speex'
        bandwidth: 2500
        streamWidth: 1600
        streamHeight: 900
        streamFPS: 20
        intervalSecs: 4
        videoQuality: 70
        embedTimecode: false
        timecodeFrequency: 999
        favorArea: true

      checkForOptions.call this, givenOptions, expectedOptions, done
