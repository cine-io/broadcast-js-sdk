ApiBridge = require('../src/api_bridge')
ajax = require('../src/vendor/ajax')
CineIO = require('../src/main')

describe 'ApiBridge', ->

  expectJSONPResponse = (url)->
    ajaxOptions = @xhrStub.firstCall.args[0]
    expect(ajaxOptions.error).to.be.instanceOf(Function)
    expect(ajaxOptions.type).to.equal("GET")
    expect(ajaxOptions.crossDomain).to.be.true
    expect(ajaxOptions.dataType).to.equal("jsonp")
    # ajax library replaces =? with =#{jsonpCallback}
    expect(ajaxOptions.url).to.equal(url)

  afterEach ->
    ApiBridge._clear()
  describe 'getStreamDetails', ->
    beforeEach ->
      successfulResponse =
        id:"THE_STREAM_ID"
        name:"my custom name"
        streamName:"streamName"
        play:
          hls:"http://hls.cine.io/cines/streamName/streamName.m3u8"
          rtmp:"rtmp://fml.cine.io/20C45E/cines/streamName?adbe-live-event=streamName"

      @xhrStub = sinon.stub(ajax, 'JSONP').yieldsTo("success", successfulResponse)

    afterEach ->
      @xhrStub.restore()

    beforeEach ->
      CineIO.init("MY_PUBLIC_KEY")

    afterEach ->
      CineIO.reset()

    beforeEach (done)->
      ApiBridge.getStreamDetails "THE_STREAM_ID", (err, response)=>
        @response = response
        done(err)

    it 'calls the right url', ->
      expectJSONPResponse.call(this, "https://www.cine.io/api/1/-/stream?publicKey=MY_PUBLIC_KEY&id=THE_STREAM_ID&callback=?")

    it 'returns the stream details', ->
      expect(@response).to.deep.equal
        id:"THE_STREAM_ID"
        name:"my custom name"
        streamName:"streamName"
        play:
          hls:"http://hls.cine.io/cines/streamName/streamName.m3u8"
          rtmp:"rtmp://fml.cine.io/20C45E/cines/streamName?adbe-live-event=streamName"

    describe 'second call', ->
      it 'does not make a second ajax call', (done)->
        ApiBridge.getStreamDetails "THE_STREAM_ID", (err, response)=>
          expect(@xhrStub.calledOnce).to.be.true
          done(err)

      it 'returns the correct data in the second ajax call', (done)->
        ApiBridge.getStreamDetails "THE_STREAM_ID", (err, response)->
          expect(response).to.deep.equal
            id:"THE_STREAM_ID"
            name:"my custom name"
            streamName:"streamName"
            play:
              hls:"http://hls.cine.io/cines/streamName/streamName.m3u8"
              rtmp:"rtmp://fml.cine.io/20C45E/cines/streamName?adbe-live-event=streamName"
          done(err)

  describe 'nearestServer', ->
    beforeEach ->
      successfulResponse =
        server:"rtmp://stream.ENDPOINT.cine.io/20C45E/cines"
        code:"lax"
        transcode:"rtmp://publish-ENDPOINT.cine.io/live"
      @xhrStub = sinon.stub(ajax, 'JSONP').yieldsTo("success", successfulResponse)

    afterEach ->
      @xhrStub.restore()

    beforeEach (done)->
      ApiBridge.nearestServer (err, response)=>
        @response = response
        done(err)

    it 'calls the right url', ->
      expectJSONPResponse.call(this, "https://www.cine.io/api/1/-/nearest-server?default=ok&callback=?")

    it 'returns the nearest server', ->
      expect(@response).to.deep.equal
        server:"rtmp://stream.ENDPOINT.cine.io/20C45E/cines"
        code:"lax"
        transcode:"rtmp://publish-ENDPOINT.cine.io/live"

    describe 'second call', ->
      it 'does not make a second ajax call', (done)->
        ApiBridge.nearestServer (err, response)=>
          expect(@xhrStub.calledOnce).to.be.true
          done(err)

      it 'returns the correct data in the second ajax call', (done)->
        ApiBridge.nearestServer (err, response)->
          expect(response).to.deep.equal
            server:"rtmp://stream.ENDPOINT.cine.io/20C45E/cines"
            code:"lax"
            transcode:"rtmp://publish-ENDPOINT.cine.io/live"
          done(err)

  describe 'getStreamRecordings', ->
    beforeEach ->
      successfulResponse =
        [
          {
            name: "SMALL_RECORDING.mp4"
            url: "http://vod.cine.io/cines/THE_PUBLIC_KEY/SMALL_RECORDING.mp4"
            size: 31457280
            date: "2014-07-31T21:30:00.000Z"
          }
          {
            name: "LARGE_RECORDING.mp4"
            url: "http://vod.cine.io/cines/THE_PUBLIC_KEY/LARGE_RECORDING.mp4"
            size: 209715200
            date: "2014-07-31T21:30:00.000Z"
          }
        ]
      @xhrStub = sinon.stub(ajax, 'JSONP').yieldsTo("success", successfulResponse)

    afterEach ->
      @xhrStub.restore()

    beforeEach ->
      CineIO.init("MY_PUBLIC_KEY")

    afterEach ->
      CineIO.reset()

    beforeEach (done)->
      ApiBridge.getStreamRecordings "THE_STREAM_ID", (err, response)=>
        @response = response
        done(err)

    it 'calls the right url', ->
      expectJSONPResponse.call(this, "https://www.cine.io/api/1/-/stream/recordings?publicKey=MY_PUBLIC_KEY&id=THE_STREAM_ID&callback=?")

    it 'returns the stream details', ->
      expect(@response).to.deep.equal(
        [
          {
            name: "SMALL_RECORDING.mp4"
            url: "http://vod.cine.io/cines/THE_PUBLIC_KEY/SMALL_RECORDING.mp4"
            size: 31457280
            date: "2014-07-31T21:30:00.000Z"
          }
          {
            name: "LARGE_RECORDING.mp4"
            url: "http://vod.cine.io/cines/THE_PUBLIC_KEY/LARGE_RECORDING.mp4"
            size: 209715200
            date: "2014-07-31T21:30:00.000Z"
          }
        ]
      )

    describe 'second call', ->
      it 'does not make a second ajax call', (done)->
        ApiBridge.getStreamRecordings "THE_STREAM_ID", (err, response)=>
          expect(@xhrStub.calledOnce).to.be.true
          done(err)

      it 'returns the correct data in the second ajax call', (done)->
        ApiBridge.getStreamRecordings "THE_STREAM_ID", (err, response)->
          expect(response).to.deep.equal(
            [
              {
                name: "SMALL_RECORDING.mp4"
                url: "http://vod.cine.io/cines/THE_PUBLIC_KEY/SMALL_RECORDING.mp4"
                size: 31457280
                date: "2014-07-31T21:30:00.000Z"
              }
              {
                name: "LARGE_RECORDING.mp4"
                url: "http://vod.cine.io/cines/THE_PUBLIC_KEY/LARGE_RECORDING.mp4"
                size: 209715200
                date: "2014-07-31T21:30:00.000Z"
              }
            ]
          )
          done(err)
