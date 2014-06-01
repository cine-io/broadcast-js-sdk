# [cine.io](cine.io) JS SDK

## Installation

```html
<script src="//cdn.cine.io/cineio.js"></script>
```

## Usage
The `CineIO` object has three main methods. The first one is `init`. Initialize CineIO jssdk with your public key. The second method is `play`. This is used to play a live stream. This works on desktop, iOS, Android devices. Sending your stream to an Apple TV and Chromecast (although I don't have a Chromecast right now, but I don't see a reason why it wouldn't work; let me know if you run into issues) should work as well. The third main method is `publish`. This is used to publish a live stream using a webcam and input source. At this time, the publisher requries flash to be installed on the client machine.

#### Init

Start off by initializing CineIO with your public publicKey.

```javascript
CineIO.init(CINE_IO_PUBLIC_KEY, options);
```
**CINE_IO_PUBLIC_KEY**
This is your public key for a [cine.io](cine.io) project.

**options**

Options are an optional parameter. Currently the only supported option is `jwPlayerKey`. Pass this in to validate your jwPlayer version. Unlicensed versions will show the jwPlayer logo.

#### Play

```javascript
CineIO.play(streamId, domId, playOptions);
```

**streamId**

streamId is a [cine.io](cine.io) stream id. This is what is returned when accessing the create stream endpoint or available in your [cine.io](cine.io) dashboard.

**domId**

domId is the ID of the dom node you want the player to be injected into.

**available/default playOptions are:**

*  stretching: 'uniform'
*  width: '100%'
*  aspectratio: '16:9'
*  primary: 'flash'
*  autostart: true
*  metaData: true
*  mute: false
*  controls: true
*  rtmp:
   * subscribe: true

#### Publish

```javascript
publisher = CineIO.publish(streamId, streamPassword, domId, publishOptions);
publisher.start(); // starts the broadcast
publisher.stop(); // stops the broadcast
```

**streamId**

streamId is a [cine.io](cine.io) stream id. This is what is returned when accessing the create stream endpoint or available in your [cine.io](cine.io) dashboard.

**streamPassword**

streamPassword is a [cine.io](cine.io) stream password. Only expose the streamPassword to your users who have permission to publish.

**domId**

domId is the ID of the dom node you want the publisher to be injected into.

**available/default publish options are:**


*  audioCodec: 'NellyMoser'
   * available options are 'NellyMoser' and 'Speex' (these are both automatically transcoded by [cine.io](cine.io) to AAC for playback on mobile devices.)
*  streamWidth: 720
*  streamHeight: 404
*  streamFPS: 15
*  intervalSecs: 10
*  bandwidth: 1500
*  videoQuality: 90

#### getStreamDetails
This is used to get the play details of the stream. For example if you wanted to use your own player, you would use this to get the stream details

```javascript
CineIO.getStreamDetails(streamId, callback);
```

**streamId**

streamId is a [cine.io](cine.io) stream id. This is what is returned when accessing the create stream endpoint or available in your [cine.io](cine.io) dashboard.

**callback**

callback is a function which returns the an error or the stream details. It follows the Node.js format of `(err, data)`. An example callback:
```javascript
function(err, stream){ console.log('recieved err/stream', err, stream); }
```

**stream response**

The stream follows the format of:
```json
{"id": "the streamId", "play": {"hls": "the hls url", "rtmp": "the rtmp url"}}
```
