playerReady = false
loadingPlayer = false
waitingPlayCalls = []

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
  getScript '//jwpsrv.com/library/sq8RfmIXEeOtdhIxOQfUww.js', playerIsReady
  enqueuePlayerCallback cb

userOrDefault = (userOptions, key)->
  if Object.prototype.hasOwnProperty.call(userOptions, key) then userOptions[key] else defaultOptions[key]


playNative = (source, domNode, playOptions)->
  videoOptions =
     width: userOrDefault(playOptions, 'width')
     height: '100%'
     autoplay: userOrDefault(playOptions, 'autostart')
     controls: userOrDefault(playOptions, 'controls')
     mute: userOrDefault(playOptions, 'mute')
     src: source
  videoElement = "<video src='#{videoOptions.src}' height='#{videoOptions.height}' #{'autoplay' if videoOptions.autoplay} #{'controls' if videoOptions.controls} #{'mute' if videoOptions.mute}>"
  document.getElementById(domNode).innerHTML = videoElement

startJWPlayer = (flashSource, nativeSouce, domNode, playOptions)->
  switchToNative = ->
    return if flashDetect()
    playNative(nativeSouce, domNode, playOptions)

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

  jwplayer(domNode).setup(options)
  jwplayer().setControls(false) if !userOrDefault(playOptions, 'controls')

  jwplayer().onReady switchToNative
  jwplayer().onSetupError switchToNative

# this assumes JW player is loaded
playLive = (streamId, domNode, playOptions)->
  ApiBridge.getStreamDetails streamId, (err, stream)->
    console.log('streaming', stream)
    startJWPlayer(stream.play.rtmp, stream.play.hls, domNode, playOptions)

getRecordingUrl = (recordings, recordingName)->
  url = null
  for recording in recordings
    return recording.url if recording.name == recordingName

playRecording = (streamId, recordingName, domNode, playOptions)->
  ApiBridge.getStreamRecordings streamId, (err, recordings)->
    recordingUrl = getRecordingUrl(recordings, recordingName)
    throw new Error("Recording not found") unless recordingUrl
    # JWPlayer totally fails when primary is set to flash.
    playOptions.primary = null
    startJWPlayer(recordingUrl, recordingUrl, domNode, playOptions)

exports.live = (streamId, domNode, playOptions)->
  ensurePlayerLoaded ->
    playLive(streamId, domNode, playOptions)

exports.recording = (streamId, recordingName, domNode, playOptions)->
  ensurePlayerLoaded ->
    playRecording(streamId, recordingName, domNode, playOptions)

getScript = require('./get_script')
flashDetect = require('./flash_detect')
ApiBridge = require('./api_bridge')
