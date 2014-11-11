urlWithProtocol = (url)->
  protocol = if urlWithProtocol._getProtocol() == 'https:' then 'https' else 'http'
  "#{protocol}://#{url}"

urlWithProtocol._getProtocol = ->
  location.protocol

module.exports = urlWithProtocol
