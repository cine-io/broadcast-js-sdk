playerReady = false
loadingPlayer = false
waitingPlayCalls = []
noop = ->

defaultOptions =
  stretching: 'uniform'
  width: '100%'
  aspectratio: '16:9'
  primary: 'flash'
  autostart: true
  metaData: true
  controls: true
  mute: false
  rtmp:
    subscribe: true

jwPlayerUrl = ->
  url = '//jwpsrv.com/library/sq8RfmIXEeOtdhIxOQfUww.js'
  protocol = if location.protocol == 'https:' then 'https:' else 'http:'
  "#{protocol}#{url}"

playerIsReady = ->
  playerReady = true
  for call in waitingPlayCalls
    call.call()
  waitingPlayCalls.length = 0

enqueuePlayerCallback = (cb)->
  waitingPlayCalls.push cb

ensurePlayerLoaded = (cb)->
  return cb() if playerReady
  return enqueuePlayerCallback(cb) if loadingPlayer
  loadingPlayer = true

  getScript urlWithProtocol('jwpsrv.com/library/sq8RfmIXEeOtdhIxOQfUww.js'), playerIsReady
  enqueuePlayerCallback cb

userOrDefault = (userOptions, key)->
  if Object.prototype.hasOwnProperty.call(userOptions, key) then userOptions[key] else defaultOptions[key]


playNative = (source, domNode, playOptions, callback)->
  videoOptions =
     width: userOrDefault(playOptions, 'width')
     height: '100%'
     autoplay: userOrDefault(playOptions, 'autostart')
     controls: userOrDefault(playOptions, 'controls')
     mute: userOrDefault(playOptions, 'mute')
     src: source
  videoElement = "<video src='#{videoOptions.src}' height='#{videoOptions.height}' #{'autoplay' if videoOptions.autoplay} #{'controls' if videoOptions.controls} #{'mute' if videoOptions.mute}>"
  videoNode = document.getElementById(domNode)
  videoNode.innerHTML = videoElement
  callback(null, videoNode)

startJWPlayer = (flashSource, nativeSouce, domNode, playOptions, callback)->
  jwplayer.key = CineIO.config.jwPlayerKey
  options =
    file: flashSource
    stretching: userOrDefault(playOptions, 'stretching')
    width: userOrDefault(playOptions, 'width')
    aspectratio: userOrDefault(playOptions, 'aspectratio')
    primary: userOrDefault(playOptions, 'primary')
    autostart: userOrDefault(playOptions, 'autostart')
    metaData: userOrDefault(playOptions, 'metaData')
    mute: userOrDefault(playOptions, 'mute')
    rtmp: userOrDefault(playOptions, 'rtmp')
    controlbar: userOrDefault(playOptions, 'controls')

  console.log('playing', options)

  player = jwplayer(domNode).setup(options)
  player.setControls(false) if !userOrDefault(playOptions, 'controls')

  switchToNative = ->
    return callback(null, player) if flashDetect()
    playNative(nativeSouce, domNode, playOptions, callback)

  player.onReady switchToNative
  player.onSetupError switchToNative

# this assumes JW player is loaded
playLive = (streamId, domNode, playOptions, callback)->
  ApiBridge.getStreamDetails streamId, (err, stream)->
    return callback(err) if err
    return callback(new Error("stream not found")) unless stream
    startJWPlayer(stream.play.rtmp, stream.play.hls, domNode, playOptions, callback)

getRecordingUrl = (recordings, recordingName)->
  url = null
  for recording in recordings
    return recording.url if recording.name == recordingName

playRecording = (streamId, recordingName, domNode, playOptions, callback)->
  ApiBridge.getStreamRecordings streamId, (err, recordings)->
    recordingUrl = getRecordingUrl(recordings, recordingName)
    return callback(err) if err
    return callback(new Error("Recording not found")) unless recordingUrl
    # JWPlayer totally fails when primary is set to flash.
    playOptions.primary = null
    startJWPlayer(recordingUrl, recordingUrl, domNode, playOptions, callback)

exports.live = (streamId, domNode, playOptions={}, callback=noop)->
  ensurePlayerLoaded ->
    if typeof playOptions == 'function'
      callback = playOptions
      playOptions = {}

    playLive(streamId, domNode, playOptions, callback)

exports.recording = (streamId, recordingName, domNode, playOptions={}, callback=noop)->
  ensurePlayerLoaded ->
    if typeof playOptions == 'function'
      callback = playOptions
      playOptions = {}
    playRecording(streamId, recordingName, domNode, playOptions, callback)

getScript = require('./vendor/get_script')
flashDetect = require('./flash_detect')
ApiBridge = require('./api_bridge')
urlWithProtocol = require('./url_with_protocol')
