flashDetect = require('../src/flash_detect')

describe 'flashDetect', ->

  describe "ActiveXObject", ->
    beforeEach ->
      global.ActiveXObject = class
        constructor: (value)->
          expect(value).to.equal("ShockwaveFlash.ShockwaveFlash")

    afterEach ->
      delete global.ActiveXObject

    it 'returns true when there is an ActiveXObject class', ->
      expect(flashDetect()).to.be.true

  describe 'navigator support', ->
    beforeEach ->
      global.navigator = {}
    afterEach ->
      delete global.navigator

    it 'returns false when the navigator does not support specific mime types', ->
      expect(flashDetect()).to.be.false

    it 'returns false when the navigator does not support application/x-shockwave-flash', ->
      navigator.mimeTypes = {}
      expect(flashDetect()).to.be.false

    it 'returns false when the navigator supports application/x-shockwave-flash but there is no information', ->
      navigator.mimeTypes = {}
      navigator.mimeTypes['application/x-shockwave-flash'] = true
      expect(flashDetect()).to.be.false

    it 'returns false when the navigator supports application/x-shockwave-flash but it is not enabled', ->
      navigator.mimeTypes = {}
      navigator.mimeTypes['application/x-shockwave-flash'] = {enabledPlugin: false}
      expect(flashDetect()).to.be.false

    it 'returns true when the navigator supports application/x-shockwave-flash', ->
      navigator.mimeTypes = {}
      navigator.mimeTypes['application/x-shockwave-flash'] = {enabledPlugin: true}
      expect(flashDetect()).to.be.true

  it 'otherwise returns false', ->
    expect(flashDetect()).to.be.false
