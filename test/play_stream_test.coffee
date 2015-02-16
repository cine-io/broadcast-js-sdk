PlayStream = require('../src/play_stream')
CineIO = require('../src/main')
ApiBridge = require('../src/api_bridge')
ajax = require('../src/vendor/ajax')
async = require('async')
flashDetect = require('../src/flash_detect')
debug = require('../src/debug')('cine:broadcast:play_stream_test')
describe 'PlayStream', ->
  unless flashDetect()
    it 'needs to be checked in the browser'
    return

  @timeout 5000

  beforeEach ->
    CineIO.init("MY_PUBLIC_KEY")

  afterEach ->
    CineIO.reset()
    ApiBridge._clear()

  beforeEach ->
    @playerDivID = 'player-id'
    @playerDiv = document.createElement('div')
    @playerDiv.id = @playerDivID
    document.body.appendChild(@playerDiv)

  describe '.live', ->
    beforeEach ->
      successfulResponse =
        id:"THE_STREAM_ID"
        name:"my custom name"
        streamName:"streamName"
        play:
          hls:"http://hls.cine.io/cines/streamName/streamName.m3u8"
          rtmp:"rtmp://fml.cine.io/20C45E/cines/streamName"

      @xhrStub = sinon.stub(ajax, 'JSONP').yieldsTo("success", successfulResponse)

    afterEach ->
      @xhrStub.restore()

    checkForPlayer = (done)->
      playerExists = false
      testFunction = -> playerExists
      checkFunction = (callback)->
        playerDiv = window.document.getElementById('player-id')
        debug('checking type', playerDiv.type)
        playerExists = playerDiv.type == 'application/x-shockwave-flash'
        setTimeout callback
      async.until testFunction, checkFunction, (err)->
        debug("GOT ERROR", err)
        done(err)

    afterEach ->
      afterJwPlayer = document.getElementById("#{@playerDivID}_wrapper")
      afterJwPlayer.parentNode.removeChild(afterJwPlayer)

    it 'plays a live file', (done)->
      domId = @playerDivID
      streamId = "theStreamId"
      PlayStream.live streamId, domId
      checkForPlayer(done)

    it 'calls back with jwplayer', (done)->
      domId = @playerDivID
      streamId = "theStreamId"
      PlayStream.live streamId, domId, (err, player)->
        expect(err).to.be.null
        expect(player.id).to.equal('player-id')
        expect(player.renderingMode).to.equal('flash')
        expect(player.onMeta).to.be.a("function")
        checkForPlayer(done)

  describe '.recording', ->
    beforeEach ->
      successfulResponse =
        [
          {
            name: "recordedFile.mp4"
            url: "https://www.youtube.com/watch?v=ixci-5EAkWA"
            size: 31457280
            date: "2014-07-31T21:30:00.000Z"
          }
        ]
      @xhrStub = sinon.stub(ajax, 'JSONP').yieldsTo("success", successfulResponse)

    afterEach ->
      @xhrStub.restore()

    checkForPlayer = (done)->
      playerExists = false
      testFunction = -> playerExists
      checkFunction = (callback)->
        playerExists = window.document.getElementById('player-id_media')?
        setTimeout callback
      async.until testFunction, checkFunction, (err)->
        debug("GOT ERROR", err)
        done(err)

    afterEach ->
      afterJwPlayer = document.getElementsByClassName('jwplayer')[0]
      afterJwPlayer.parentNode.removeChild(afterJwPlayer)

    it 'plays a recorded file', (done)->
      domId = @playerDivID
      streamId = "theStreamId"
      PlayStream.recording streamId, "recordedFile.mp4", domId
      checkForPlayer(done)

    it 'calls back with jwplayer', (done)->
      domId = @playerDivID
      streamId = "theStreamId"
      PlayStream.recording streamId, "recordedFile.mp4", domId, (err, player)->
        expect(err).to.be.null
        expect(player.id).to.equal('player-id')
        expect(player.onMeta).to.be.a("function")
        checkForPlayer(done)
