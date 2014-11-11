urlWithProtocol = require('../src/url_with_protocol')

describe 'urlWithProtocol', ->

  protocols = [
    {protocol: 'http', expected: 'http'}
    {protocol: 'https', expected: 'https'}
    {protocol: 'file', expected: 'http'}
  ]

  stubProtocol = (protocol)->
    beforeEach ->
      @protocolStub = sinon.stub(urlWithProtocol, '_getProtocol').returns(protocol)
    afterEach ->
      @protocolStub.restore()

  protocols.forEach (test)->
    describe "with #{test.protocol}:", ->
      stubProtocol.call(this, "#{test.protocol}:")
      it "enforces #{test.expected}", ->
        expect(urlWithProtocol("hello")).to.equal("#{test.expected}://hello")
