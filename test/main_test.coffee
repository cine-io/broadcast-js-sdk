CineIO = require('../src/main')
PlayStream = require('../src/play_stream')
PublishStream = require('../src/publish_stream')
ApiBridge = require('../src/api_bridge')

describe 'CineIO', ->

  afterEach CineIO.reset

  describe '.config', ->
    it 'starts empty', ->
      expect(CineIO.config).to.be.empty
      expect(CineIO.config).to.be.instanceOf(Object)

  describe '.init', ->
    it 'has an init funciton', ->
      CineIO.init("MY_PUBLIC_KEY")
      expect(CineIO.config).to.deep.equal(publicKey: "MY_PUBLIC_KEY")

    it 'takes options too', ->
      CineIO.init("MY_PUBLIC_KEY", abc: 'def', ghi: 'jkl')
      expect(CineIO.config).to.deep.equal(publicKey: "MY_PUBLIC_KEY", abc: 'def', ghi: 'jkl')

  describe '.reset', ->
    it 'clears the config', ->
      CineIO.init("MY_PUBLIC_KEY")
      expect(CineIO.config).to.deep.equal(publicKey: "MY_PUBLIC_KEY")
      CineIO.reset()
      expect(CineIO.config).to.be.empty
      expect(CineIO.config).to.be.instanceOf(Object)

  requiresInit = (functionName)->
    it 'requires CineIO to be initialized', ->
      expect(CineIO[functionName]).to.throw(Error, "CineIO.init(CINE_IO_PUBLIC_KEY) has not been called.")

  requiresStreamId = (functionName)->
    it 'requires a stream id', ->
      expect(CineIO[functionName]).to.throw(Error, "Stream ID required.")

  initCineIO = ->
    beforeEach ->
      CineIO.init("MY_PUBLIC_KEY")

  describe '.publish', ->
    requiresInit('publish')
    describe 'after initialized', ->
      initCineIO()
      requiresStreamId('publish')
      it 'requires a password', ->
        fn = -> CineIO.publish("FAKE_STREAM_ID")
        expect(fn).to.throw(Error, "Password required.")
      it 'requires a DOM Node', ->
        fn = -> CineIO.publish("FAKE_STREAM_ID", "FAKE_PASSWORD")
        expect(fn).to.throw(Error, "DOM node required.")
      describe 'success', ->
        beforeEach ->
          @publishStub = sinon.stub PublishStream, 'new'

        afterEach ->
          @publishStub.restore()

        it 'calls to PublishStream', ->
          CineIO.publish("FAKE_STREAM_ID", 'FAKE_PASSWORD', 'fake-dom-id')
          expect(@publishStub.calledOnce).to.be.true
          args = @publishStub.firstCall.args
          expect(args).to.deep.equal(["FAKE_STREAM_ID", 'FAKE_PASSWORD', 'fake-dom-id', {}])

  describe '.play', ->
    requiresInit('play')
    describe 'after initialized', ->
      initCineIO()
      requiresStreamId('play')
      it 'requires a DOM Node', ->
        fn = -> CineIO.play("FAKE_STREAM_ID")
        expect(fn).to.throw(Error, "DOM node required.")

      describe 'success', ->
        beforeEach ->
          @playStub = sinon.stub PlayStream, 'live'

        afterEach ->
          @playStub.restore()

        it 'calls to PlayStream', ->
          CineIO.play("FAKE_STREAM_ID", 'fake-dom-id')
          expect(@playStub.calledOnce).to.be.true
          args = @playStub.firstCall.args
          expect(args).to.deep.equal(["FAKE_STREAM_ID", 'fake-dom-id', {}])

  describe '.playRecording', ->
    requiresInit('playRecording')
    describe 'after initialized', ->
      initCineIO()
      requiresStreamId('playRecording')
      it 'requires a recordingName', ->
        fn = -> CineIO.playRecording("FAKE_STREAM_ID")
        expect(fn).to.throw(Error, "Recording name required.")
      it 'requires a DOM Node', ->
        fn = -> CineIO.playRecording("FAKE_STREAM_ID", "FAKE_RECORDING_NAME")
        expect(fn).to.throw(Error, "DOM node required.")

      describe 'success', ->
        beforeEach ->
          @playRecordingStub = sinon.stub PlayStream, 'recording'

        afterEach ->
          @playRecordingStub.restore()

        it 'calls to PlayStream', ->
          CineIO.playRecording("FAKE_STREAM_ID", 'fakeRecording.mp4', 'fake-dom-id')
          expect(@playRecordingStub.calledOnce).to.be.true
          args = @playRecordingStub.firstCall.args
          expect(args).to.deep.equal(["FAKE_STREAM_ID", 'fakeRecording.mp4', 'fake-dom-id', {}])

  describe '.getStreamDetails', ->
    requiresInit('getStreamDetails')
    describe 'after initialized', ->
      initCineIO()
      requiresStreamId('getStreamDetails')

      describe 'success', ->
        beforeEach ->
          @getStreamDetailsStub = sinon.stub ApiBridge, 'getStreamDetails'

        afterEach ->
          @getStreamDetailsStub.restore()

        it 'calls to the ApiBridge', ->
          CineIO.getStreamDetails("FAKE_STREAM_ID", "the callback")
          expect(@getStreamDetailsStub.calledOnce).to.be.true
          args = @getStreamDetailsStub.firstCall.args
          expect(args).to.deep.equal(["FAKE_STREAM_ID", 'the callback'])

  describe '.getStreamRecordings', ->
    requiresInit('getStreamRecordings')
    describe 'after initialized', ->
      initCineIO()
      requiresStreamId('getStreamRecordings')

      describe 'success', ->
        beforeEach ->
          @getStreamRecordingsStub = sinon.stub ApiBridge, 'getStreamRecordings'

        afterEach ->
          @getStreamRecordingsStub.restore()

        it 'calls to the ApiBridge', ->
          CineIO.getStreamRecordings("FAKE_STREAM_ID", "the callback")
          expect(@getStreamRecordingsStub.calledOnce).to.be.true
          args = @getStreamRecordingsStub.firstCall.args
          expect(args).to.deep.equal(["FAKE_STREAM_ID", 'the callback', undefined])

        it 'calls to the ApiBridge with options', ->
          CineIO.getStreamRecordings("FAKE_STREAM_ID", "the options", "the callback")
          expect(@getStreamRecordingsStub.calledOnce).to.be.true
          args = @getStreamRecordingsStub.firstCall.args
          expect(args).to.deep.equal(["FAKE_STREAM_ID", "the options", 'the callback'])
