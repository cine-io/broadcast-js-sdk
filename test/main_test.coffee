CineIO = require('../src/main')

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

  describe '.play', ->
    requiresInit('play')
    describe 'after initialized', ->
      initCineIO()
      requiresStreamId('play')
      it 'requires a DOM Node', ->
        fn = -> CineIO.play("FAKE_STREAM_ID")
        expect(fn).to.throw(Error, "DOM node required.")

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

  describe '.getStreamDetails', ->
    requiresInit('getStreamDetails')
    describe 'after initialized', ->
      initCineIO()
      requiresStreamId('getStreamDetails')

  describe '.getStreamRecordings', ->
    requiresInit('getStreamRecordings')
    describe 'after initialized', ->
      initCineIO()
      requiresStreamId('getStreamRecordings')
