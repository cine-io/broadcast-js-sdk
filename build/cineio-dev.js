(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var toString = Object.prototype.toString

module.exports = function(val){
  switch (toString.call(val)) {
    case '[object Function]': return 'function'
    case '[object Date]': return 'date'
    case '[object RegExp]': return 'regexp'
    case '[object Arguments]': return 'arguments'
    case '[object Array]': return 'array'
    case '[object String]': return 'string'
  }

  if (typeof val == 'object' && val && typeof val.length == 'number') {
    try {
      if (typeof val.callee == 'function') return 'arguments';
    } catch (ex) {
      if (ex instanceof TypeError) {
        return 'arguments';
      }
    }
  }

  if (val === null) return 'null'
  if (val === undefined) return 'undefined'
  if (val && val.nodeType === 1) return 'element'
  if (val === Object(val)) return 'object'

  return typeof val
}

},{}],2:[function(require,module,exports){
var BASE_URL, Main, ajax, cachedResponses, fetchUrlWitCallback;

BASE_URL = "https://www.cine.io/api/1/-";

cachedResponses = {};

fetchUrlWitCallback = function(url, errorMessage, callback) {
  if (cachedResponses[url]) {
    setTimeout(function() {
      return callback(null, cachedResponses[url]);
    });
  } else {
    ajax({
      url: url,
      dataType: 'jsonp',
      success: function(data, response, xhr) {
        cachedResponses[url] = data;
        return callback(null, data);
      },
      error: function() {
        return callback(errorMessage);
      }
    });
  }
  return null;
};

exports.getStreamDetails = function(streamId, callback) {
  var errorMessage, url;
  url = "" + BASE_URL + "/stream?publicKey=" + Main.config.publicKey + "&id=" + streamId;
  errorMessage = "Could not fetch stream " + streamId;
  return fetchUrlWitCallback(url, errorMessage, callback);
};

exports.nearestServer = function(callback) {
  var errorMessage, url;
  url = "" + BASE_URL + "/nearest-server?default=ok";
  errorMessage = "Could not fetch nearest server";
  return fetchUrlWitCallback(url, errorMessage, callback);
};

exports.getStreamRecordings = function(streamId, callback) {
  var errorMessage, url;
  url = "" + BASE_URL + "/stream/recordings?publicKey=" + Main.config.publicKey + "&id=" + streamId;
  errorMessage = "Could not fetch stream recordings for " + streamId;
  return fetchUrlWitCallback(url, errorMessage, callback);
};

exports._clear = function() {
  return cachedResponses = {};
};

Main = require('./main');

ajax = require('./vendor/ajax');



},{"./main":4,"./vendor/ajax":7}],3:[function(require,module,exports){
var getNavigator, newNavigator;

newNavigator = null;

getNavigator = function() {
  return newNavigator || navigator;
};

module.exports = function() {
  var e;
  try {
    if (new ActiveXObject("ShockwaveFlash.ShockwaveFlash")) {
      return true;
    }
  } catch (_error) {
    e = _error;
    if (typeof getNavigator() === 'undefined') {
      return false;
    }
    if (!getNavigator().mimeTypes) {
      return false;
    }
    if (getNavigator().mimeTypes["application/x-shockwave-flash"] === void 0) {
      return false;
    }
    if (getNavigator().mimeTypes["application/x-shockwave-flash"].enabledPlugin) {
      return true;
    }
  }
  return false;
};

module.exports._injectNavigator = function(nav) {
  return newNavigator = nav;
};



},{}],4:[function(require,module,exports){
var ApiBridge, CineIO, PlayStream, PublishStream, requiresInit;

requiresInit = function() {
  if (!CineIO.config.publicKey) {
    throw new Error("CineIO.init(CINE_IO_PUBLIC_KEY) has not been called.");
  }
};

CineIO = {
  version: "0.1.1",
  config: {},
  init: function(publicKey, options) {
    var prop, value, _results;
    if (!publicKey) {
      throw new Error("Public Key required");
    }
    CineIO.config.publicKey = publicKey;
    _results = [];
    for (prop in options) {
      value = options[prop];
      _results.push(CineIO.config[prop] = value);
    }
    return _results;
  },
  reset: function() {
    return CineIO.config = {};
  },
  publish: function(streamId, password, domNode, publishOptions) {
    if (publishOptions == null) {
      publishOptions = {};
    }
    requiresInit();
    if (!streamId) {
      throw new Error("Stream ID required.");
    }
    if (!password) {
      throw new Error("Password required.");
    }
    if (!domNode) {
      throw new Error("DOM node required.");
    }
    return PublishStream["new"](streamId, password, domNode, publishOptions);
  },
  play: function(streamId, domNode, playOptions) {
    if (playOptions == null) {
      playOptions = {};
    }
    requiresInit();
    if (!streamId) {
      throw new Error("Stream ID required.");
    }
    if (!domNode) {
      throw new Error("DOM node required.");
    }
    return PlayStream.live(streamId, domNode, playOptions);
  },
  playRecording: function(streamId, recordingName, domNode, playOptions) {
    if (playOptions == null) {
      playOptions = {};
    }
    requiresInit();
    if (!streamId) {
      throw new Error("Stream ID required.");
    }
    if (!recordingName) {
      throw new Error("Recording name required.");
    }
    if (!domNode) {
      throw new Error("DOM node required.");
    }
    return PlayStream.recording(streamId, recordingName, domNode, playOptions);
  },
  getStreamDetails: function(streamId, callback) {
    requiresInit();
    if (!streamId) {
      throw new Error("Stream ID required.");
    }
    return ApiBridge.getStreamDetails(streamId, callback);
  },
  getStreamRecordings: function(streamId, callback) {
    requiresInit();
    if (!streamId) {
      throw new Error("Stream ID required.");
    }
    return ApiBridge.getStreamRecordings(streamId, callback);
  }
};

if (typeof window !== 'undefined') {
  window.CineIO = CineIO;
}

module.exports = CineIO;

PlayStream = require('./play_stream');

PublishStream = require('./publish_stream');

ApiBridge = require('./api_bridge');



},{"./api_bridge":2,"./play_stream":5,"./publish_stream":6}],5:[function(require,module,exports){
var ApiBridge, defaultOptions, enqueuePlayerCallback, ensurePlayerLoaded, flashDetect, getRecordingUrl, getScript, jwPlayerUrl, loadingPlayer, playLive, playNative, playRecording, playerIsReady, playerReady, startJWPlayer, userOrDefault, waitingPlayCalls;

playerReady = false;

loadingPlayer = false;

waitingPlayCalls = [];

defaultOptions = {
  stretching: 'uniform',
  width: '100%',
  aspectratio: '16:9',
  primary: 'flash',
  autostart: true,
  metaData: true,
  controls: true,
  mute: false,
  rtmp: {
    subscribe: true
  }
};

jwPlayerUrl = function() {
  var protocol, url;
  url = '//jwpsrv.com/library/sq8RfmIXEeOtdhIxOQfUww.js';
  protocol = location.protocol === 'https:' ? 'https:' : 'http:';
  return "" + protocol + url;
};

playerIsReady = function() {
  var call, _i, _len;
  playerReady = true;
  for (_i = 0, _len = waitingPlayCalls.length; _i < _len; _i++) {
    call = waitingPlayCalls[_i];
    call.call();
  }
  return waitingPlayCalls.length = 0;
};

enqueuePlayerCallback = function(cb) {
  return waitingPlayCalls.push(cb);
};

ensurePlayerLoaded = function(cb) {
  if (playerReady) {
    return cb();
  }
  if (loadingPlayer) {
    return enqueuePlayerCallback(cb);
  }
  loadingPlayer = true;
  getScript(jwPlayerUrl(), playerIsReady);
  return enqueuePlayerCallback(cb);
};

userOrDefault = function(userOptions, key) {
  if (Object.prototype.hasOwnProperty.call(userOptions, key)) {
    return userOptions[key];
  } else {
    return defaultOptions[key];
  }
};

playNative = function(source, domNode, playOptions) {
  var videoElement, videoOptions;
  videoOptions = {
    width: userOrDefault(playOptions, 'width'),
    height: '100%',
    autoplay: userOrDefault(playOptions, 'autostart'),
    controls: userOrDefault(playOptions, 'controls'),
    mute: userOrDefault(playOptions, 'mute'),
    src: source
  };
  videoElement = "<video src='" + videoOptions.src + "' height='" + videoOptions.height + "' " + (videoOptions.autoplay ? 'autoplay' : void 0) + " " + (videoOptions.controls ? 'controls' : void 0) + " " + (videoOptions.mute ? 'mute' : void 0) + ">";
  return document.getElementById(domNode).innerHTML = videoElement;
};

startJWPlayer = function(flashSource, nativeSouce, domNode, playOptions) {
  var options, switchToNative;
  switchToNative = function() {
    if (flashDetect()) {
      return;
    }
    return playNative(nativeSouce, domNode, playOptions);
  };
  jwplayer.key = CineIO.config.jwPlayerKey;
  options = {
    file: flashSource,
    stretching: userOrDefault(playOptions, 'stretching'),
    width: userOrDefault(playOptions, 'width'),
    aspectratio: userOrDefault(playOptions, 'aspectratio'),
    primary: userOrDefault(playOptions, 'primary'),
    autostart: userOrDefault(playOptions, 'autostart'),
    metaData: userOrDefault(playOptions, 'metaData'),
    mute: userOrDefault(playOptions, 'mute'),
    rtmp: userOrDefault(playOptions, 'rtmp'),
    controlbar: userOrDefault(playOptions, 'controls')
  };
  console.log('playing', options);
  jwplayer(domNode).setup(options);
  if (!userOrDefault(playOptions, 'controls')) {
    jwplayer().setControls(false);
  }
  jwplayer().onReady(switchToNative);
  return jwplayer().onSetupError(switchToNative);
};

playLive = function(streamId, domNode, playOptions) {
  return ApiBridge.getStreamDetails(streamId, function(err, stream) {
    console.log('streaming', stream);
    return startJWPlayer(stream.play.rtmp, stream.play.hls, domNode, playOptions);
  });
};

getRecordingUrl = function(recordings, recordingName) {
  var recording, url, _i, _len;
  url = null;
  for (_i = 0, _len = recordings.length; _i < _len; _i++) {
    recording = recordings[_i];
    if (recording.name === recordingName) {
      return recording.url;
    }
  }
};

playRecording = function(streamId, recordingName, domNode, playOptions) {
  return ApiBridge.getStreamRecordings(streamId, function(err, recordings) {
    var recordingUrl;
    recordingUrl = getRecordingUrl(recordings, recordingName);
    if (!recordingUrl) {
      throw new Error("Recording not found");
    }
    playOptions.primary = null;
    return startJWPlayer(recordingUrl, recordingUrl, domNode, playOptions);
  });
};

exports.live = function(streamId, domNode, playOptions) {
  if (playOptions == null) {
    playOptions = {};
  }
  return ensurePlayerLoaded(function() {
    return playLive(streamId, domNode, playOptions);
  });
};

exports.recording = function(streamId, recordingName, domNode, playOptions) {
  if (playOptions == null) {
    playOptions = {};
  }
  return ensurePlayerLoaded(function() {
    return playRecording(streamId, recordingName, domNode, playOptions);
  });
};

getScript = require('./vendor/get_script');

flashDetect = require('./flash_detect');

ApiBridge = require('./api_bridge');



},{"./api_bridge":2,"./flash_detect":3,"./vendor/get_script":8}],6:[function(require,module,exports){
var ApiBridge, DEFAULT_BASE_URL, PUBLISHER_NAME, PUBLISHER_URL, Publisher, defaultOptions, enqueuePublisherCallback, findPublisherInDom, generateStreamName, getPublisher, getScript, loadPublisher, loadedSWF, loadingSWF, noop, publisherIsLoading, publisherIsReady, publisherReady, swfObjectCallbackToLoadPublisher, waitingPublishCalls,
  __slice = [].slice;

publisherReady = false;

loadingSWF = false;

loadedSWF = false;

waitingPublishCalls = {};

DEFAULT_BASE_URL = 'rtmp://publish-west.cine.io/live';

PUBLISHER_NAME = 'Publisher';

PUBLISHER_URL = '//cdn.cine.io/publisher.swf';

noop = function() {};

defaultOptions = {
  serverURL: null,
  streamName: null,
  streamKey: null,
  audioCodec: 'NellyMoser',
  streamWidth: 720,
  streamHeight: 404,
  streamFPS: 15,
  keyFrameInterval: null,
  intervalSecs: 10,
  bandwidth: 1500,
  videoQuality: 90
};

loadPublisher = function(domNode, publishOptions, publishReadyCallback) {
  var attributes, domWidth, flashvars, height, params, streamHeight, streamWidth, swfVersionStr, url, xiSwfUrlStr;
  swfVersionStr = "11.4.0";
  xiSwfUrlStr = "playerProductInstall.swf";
  flashvars = {};
  params = {};
  attributes = {};
  params.allowscriptaccess = "always";
  params.allowfullscreen = "true";
  params.wmode = 'transparent';
  attributes.id = domNode;
  attributes.name = PUBLISHER_NAME;
  attributes.align = "middle";
  domWidth = document.getElementById(domNode).offsetWidth;
  streamWidth = publishOptions.streamWidth || defaultOptions.streamWidth;
  streamHeight = publishOptions.streamHeight || defaultOptions.streamHeight;
  height = domWidth / (streamWidth / streamHeight);
  url = "" + window.location.protocol + PUBLISHER_URL;
  return swfobject.embedSWF(url, domNode, "100%", height, swfVersionStr, xiSwfUrlStr, flashvars, params, attributes, function(embedEvent) {
    var readyCall;
    if (embedEvent.success) {
      readyCall = function() {
        embedEvent.ref.setOptions({
          jsLogFunction: "_jsLogFunction",
          jsEmitFunction: "_publisherEmit"
        });
        return publisherIsReady(domNode);
      };
      return setTimeout(readyCall, 1000);
    }
  });
};

publisherIsReady = function(domNode) {
  var call, _i, _len, _ref;
  console.log('publisher is ready!!!');
  publisherReady = true;
  _ref = waitingPublishCalls[domNode];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    call = _ref[_i];
    call.call();
  }
  return delete waitingPublishCalls[domNode];
};

enqueuePublisherCallback = function(domNode, publishOptions, cb) {
  waitingPublishCalls[domNode] || (waitingPublishCalls[domNode] = []);
  return waitingPublishCalls[domNode].push(function() {
    console.log("HERE I AM");
    return getPublisher(domNode, publishOptions, cb);
  });
};

findPublisherInDom = function(domNode) {
  var node;
  node = document.getElementById(domNode);
  if (node && node.data === (window.location.protocol + PUBLISHER_URL)) {
    return node;
  }
  return null;
};

swfObjectCallbackToLoadPublisher = function(domNode, publishOptions) {
  return function() {
    loadedSWF = true;
    return loadPublisher(domNode, publishOptions);
  };
};

publisherIsLoading = function(domNode) {
  return waitingPublishCalls[domNode] != null;
};

getPublisher = function(domNode, publishOptions, cb) {
  var publisher;
  publisher = findPublisherInDom(domNode);
  if (publisher) {
    return cb(publisher);
  }
  if (publisherIsLoading(domNode)) {
    return enqueuePublisherCallback(domNode, publishOptions, cb);
  }
  enqueuePublisherCallback(domNode, publishOptions, cb);
  if (loadedSWF) {
    return loadPublisher(domNode, publishOptions);
  } else {
    return getScript('//ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js', swfObjectCallbackToLoadPublisher(domNode, publishOptions, cb));
  }
};

generateStreamName = function(stream, password) {
  return "" + stream.streamName + "?" + password + "&adbe-live-event=" + stream.streamName;
};

Publisher = (function() {
  function Publisher(streamId, password, domNode, publishOptions, callback) {
    this.streamId = streamId;
    this.password = password;
    this.domNode = domNode;
    this.publishOptions = publishOptions != null ? publishOptions : {};
    if (callback == null) {
      callback = noop;
    }
    if (typeof this.publishOptions === 'function') {
      callback = publishOptions;
      this.publishOptions = {};
    }
    this._ensureLoaded(callback);
  }

  Publisher.prototype.start = function(callback) {
    if (callback == null) {
      callback = noop;
    }
    return this._ensureLoaded((function(_this) {
      return function(publisher) {
        console.log('fetching stream', publisher);
        return ApiBridge.getStreamDetails(_this.streamId, function(err, stream) {
          var options;
          options = _this._options(stream);
          console.log('streamingggg!!', options);
          console.log("SET OPTIONS", publisher.setOptions);
          publisher.setOptions(options);
          publisher.start();
          return callback();
        });
      };
    })(this));
  };

  Publisher.prototype.stop = function(callback) {
    if (callback == null) {
      callback = noop;
    }
    return this._ensureLoaded(function(publisher) {
      var e;
      try {
        publisher.stop();
      } catch (_error) {
        e = _error;
        return callback(e);
      }
      return callback();
    });
  };

  Publisher.prototype._options = function(stream) {
    var intervalSecs, options;
    options = {
      serverURL: this.serverURL || DEFAULT_BASE_URL,
      streamName: generateStreamName(stream, this.password),
      audioCodec: this.publishOptions.audioCodec || defaultOptions.audioCodec,
      streamWidth: this.publishOptions.streamWidth || defaultOptions.streamWidth,
      streamHeight: this.publishOptions.streamHeight || defaultOptions.streamHeight,
      streamFPS: this.publishOptions.streamFPS || defaultOptions.streamFPS,
      bandwidth: this.publishOptions.bandwidth || defaultOptions.bandwidth * 1024 * 8,
      videoQuality: this.publishOptions.videoQuality || defaultOptions.videoQuality
    };
    intervalSecs = this.publishOptions.intervalSecs || defaultOptions.intervalSecs;
    options.keyFrameInterval = options.streamFPS * intervalSecs;
    return options;
  };

  Publisher.prototype._ensureLoaded = function(cb) {
    if (cb == null) {
      cb = noop;
    }
    return ApiBridge.nearestServer((function(_this) {
      return function(err, data) {
        _this.serverUrl = data.transcode;
        return getPublisher(_this.domNode, _this.publishOptions, cb);
      };
    })(this));
  };

  return Publisher;

})();

exports["new"] = function(streamId, password, domNode, publishOptions) {
  if (publishOptions == null) {
    publishOptions = {};
  }
  return new Publisher(streamId, password, domNode, publishOptions);
};

window._publisherEmit = function() {
  var eventName, stuff;
  eventName = arguments[0], stuff = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  switch (eventName) {
    case "connect":
    case "disconnect":
    case "publish":
    case "status":
    case "error":
      return console.log.apply(console, stuff);
    default:
      return console.log.apply(console, stuff);
  }
};

window._jsLogFunction = function(msg) {
  return console.log('_jsLogFunction', msg);
};

getScript = require('./vendor/get_script');

ApiBridge = require('./api_bridge');



},{"./api_bridge":2,"./vendor/get_script":8}],7:[function(require,module,exports){
// https://github.com/ForbesLindesay/ajax
var type
try {
  type = require('type-of')
} catch (ex) {
  //hide from browserify
  var r = require
  type = r('type')
}

var jsonpID = 0,
    document = window.document,
    key,
    name,
    rscript = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi,
    scriptTypeRE = /^(?:text|application)\/javascript/i,
    xmlTypeRE = /^(?:text|application)\/xml/i,
    jsonType = 'application/json',
    htmlType = 'text/html',
    blankRE = /^\s*$/

var ajax = module.exports = function(options){
  var settings = extend({}, options || {})
  for (key in ajax.settings) if (settings[key] === undefined) settings[key] = ajax.settings[key]

  ajaxStart(settings)

  if (!settings.crossDomain) settings.crossDomain = /^([\w-]+:)?\/\/([^\/]+)/.test(settings.url) &&
    RegExp.$2 != window.location.host

  var dataType = settings.dataType, hasPlaceholder = /=\?/.test(settings.url)
  if (dataType == 'jsonp' || hasPlaceholder) {
    if (!hasPlaceholder) settings.url = appendQuery(settings.url, 'callback=?')
    return ajax.JSONP(settings)
  }

  if (!settings.url) settings.url = window.location.toString()
  serializeData(settings)

  var mime = settings.accepts[dataType],
      baseHeaders = { },
      protocol = /^([\w-]+:)\/\//.test(settings.url) ? RegExp.$1 : window.location.protocol,
      xhr = ajax.settings.xhr(), abortTimeout

  if (!settings.crossDomain) baseHeaders['X-Requested-With'] = 'XMLHttpRequest'
  if (mime) {
    baseHeaders['Accept'] = mime
    if (mime.indexOf(',') > -1) mime = mime.split(',', 2)[0]
    xhr.overrideMimeType && xhr.overrideMimeType(mime)
  }
  if (settings.contentType || (settings.data && settings.type.toUpperCase() != 'GET'))
    baseHeaders['Content-Type'] = (settings.contentType || 'application/x-www-form-urlencoded')
  settings.headers = extend(baseHeaders, settings.headers || {})

  xhr.onreadystatechange = function(){
    if (xhr.readyState == 4) {
      clearTimeout(abortTimeout)
      var result, error = false
      if ((xhr.status >= 200 && xhr.status < 300) || xhr.status == 304 || (xhr.status == 0 && protocol == 'file:')) {
        dataType = dataType || mimeToDataType(xhr.getResponseHeader('content-type'))
        result = xhr.responseText

        try {
          if (dataType == 'script')    (1,eval)(result)
          else if (dataType == 'xml')  result = xhr.responseXML
          else if (dataType == 'json') result = blankRE.test(result) ? null : JSON.parse(result)
        } catch (e) { error = e }

        if (error) ajaxError(error, 'parsererror', xhr, settings)
        else ajaxSuccess(result, xhr, settings)
      } else {
        ajaxError(null, 'error', xhr, settings)
      }
    }
  }

  var async = 'async' in settings ? settings.async : true
  xhr.open(settings.type, settings.url, async)

  for (name in settings.headers) xhr.setRequestHeader(name, settings.headers[name])

  if (ajaxBeforeSend(xhr, settings) === false) {
    xhr.abort()
    return false
  }

  if (settings.timeout > 0) abortTimeout = setTimeout(function(){
      xhr.onreadystatechange = empty
      xhr.abort()
      ajaxError(null, 'timeout', xhr, settings)
    }, settings.timeout)

  // avoid sending empty string (#319)
  xhr.send(settings.data ? settings.data : null)
  return xhr
}


// trigger a custom event and return false if it was cancelled
function triggerAndReturn(context, eventName, data) {
  //todo: Fire off some events
  //var event = $.Event(eventName)
  //$(context).trigger(event, data)
  return true;//!event.defaultPrevented
}

// trigger an Ajax "global" event
function triggerGlobal(settings, context, eventName, data) {
  if (settings.global) return triggerAndReturn(context || document, eventName, data)
}

// Number of active Ajax requests
ajax.active = 0

function ajaxStart(settings) {
  if (settings.global && ajax.active++ === 0) triggerGlobal(settings, null, 'ajaxStart')
}
function ajaxStop(settings) {
  if (settings.global && !(--ajax.active)) triggerGlobal(settings, null, 'ajaxStop')
}

// triggers an extra global event "ajaxBeforeSend" that's like "ajaxSend" but cancelable
function ajaxBeforeSend(xhr, settings) {
  var context = settings.context
  if (settings.beforeSend.call(context, xhr, settings) === false ||
      triggerGlobal(settings, context, 'ajaxBeforeSend', [xhr, settings]) === false)
    return false

  triggerGlobal(settings, context, 'ajaxSend', [xhr, settings])
}
function ajaxSuccess(data, xhr, settings) {
  var context = settings.context, status = 'success'
  settings.success.call(context, data, status, xhr)
  triggerGlobal(settings, context, 'ajaxSuccess', [xhr, settings, data])
  ajaxComplete(status, xhr, settings)
}
// type: "timeout", "error", "abort", "parsererror"
function ajaxError(error, type, xhr, settings) {
  var context = settings.context
  settings.error.call(context, xhr, type, error)
  triggerGlobal(settings, context, 'ajaxError', [xhr, settings, error])
  ajaxComplete(type, xhr, settings)
}
// status: "success", "notmodified", "error", "timeout", "abort", "parsererror"
function ajaxComplete(status, xhr, settings) {
  var context = settings.context
  settings.complete.call(context, xhr, status)
  triggerGlobal(settings, context, 'ajaxComplete', [xhr, settings])
  ajaxStop(settings)
}

// Empty function, used as default callback
function empty() {}

ajax.JSONP = function(options){
  if (!('type' in options)) return ajax(options)

  var callbackName = 'jsonp' + (++jsonpID),
    script = document.createElement('script'),
    abort = function(){
      //todo: remove script
      //$(script).remove()
      if (callbackName in window) window[callbackName] = empty
      ajaxComplete('abort', xhr, options)
    },
    xhr = { abort: abort }, abortTimeout,
    head = document.getElementsByTagName("head")[0]
      || document.documentElement

  if (options.error) script.onerror = function() {
    xhr.abort()
    options.error()
  }

  window[callbackName] = function(data){
    clearTimeout(abortTimeout)
      //todo: remove script
      //$(script).remove()
    delete window[callbackName]
    ajaxSuccess(data, xhr, options)
  }

  serializeData(options)
  script.src = options.url.replace(/=\?/, '=' + callbackName)

  // Use insertBefore instead of appendChild to circumvent an IE6 bug.
  // This arises when a base node is used (see jQuery bugs #2709 and #4378).
  head.insertBefore(script, head.firstChild);

  if (options.timeout > 0) abortTimeout = setTimeout(function(){
      xhr.abort()
      ajaxComplete('timeout', xhr, options)
    }, options.timeout)

  return xhr
}

ajax.settings = {
  // Default type of request
  type: 'GET',
  // Callback that is executed before request
  beforeSend: empty,
  // Callback that is executed if the request succeeds
  success: empty,
  // Callback that is executed the the server drops error
  error: empty,
  // Callback that is executed on request complete (both: error and success)
  complete: empty,
  // The context for the callbacks
  context: null,
  // Whether to trigger "global" Ajax events
  global: true,
  // Transport
  xhr: function () {
    return new window.XMLHttpRequest()
  },
  // MIME types mapping
  accepts: {
    script: 'text/javascript, application/javascript',
    json:   jsonType,
    xml:    'application/xml, text/xml',
    html:   htmlType,
    text:   'text/plain'
  },
  // Whether the request is to another domain
  crossDomain: false,
  // Default timeout
  timeout: 0
}

function mimeToDataType(mime) {
  return mime && ( mime == htmlType ? 'html' :
    mime == jsonType ? 'json' :
    scriptTypeRE.test(mime) ? 'script' :
    xmlTypeRE.test(mime) && 'xml' ) || 'text'
}

function appendQuery(url, query) {
  return (url + '&' + query).replace(/[&?]{1,2}/, '?')
}

// serialize payload and append it to the URL for GET requests
function serializeData(options) {
  if (type(options.data) === 'object') options.data = param(options.data)
  if (options.data && (!options.type || options.type.toUpperCase() == 'GET'))
    options.url = appendQuery(options.url, options.data)
}

ajax.get = function(url, success){ return ajax({ url: url, success: success }) }

ajax.post = function(url, data, success, dataType){
  if (type(data) === 'function') dataType = dataType || success, success = data, data = null
  return ajax({ type: 'POST', url: url, data: data, success: success, dataType: dataType })
}

ajax.getJSON = function(url, success){
  return ajax({ url: url, success: success, dataType: 'json' })
}

var escape = encodeURIComponent

function serialize(params, obj, traditional, scope){
  var array = type(obj) === 'array';
  for (var key in obj) {
    var value = obj[key];

    if (scope) key = traditional ? scope : scope + '[' + (array ? '' : key) + ']'
    // handle data in serializeArray() format
    if (!scope && array) params.add(value.name, value.value)
    // recurse into nested objects
    else if (traditional ? (type(value) === 'array') : (type(value) === 'object'))
      serialize(params, value, traditional, key)
    else params.add(key, value)
  }
}

function param(obj, traditional){
  var params = []
  params.add = function(k, v){ this.push(escape(k) + '=' + escape(v)) }
  serialize(params, obj, traditional)
  return params.join('&').replace('%20', '+')
}

function extend(target) {
  var slice = Array.prototype.slice;
  slice.call(arguments, 1).forEach(function(source) {
    for (key in source)
      if (source[key] !== undefined)
        target[key] = source[key]
  })
  return target
}

},{"type-of":1}],8:[function(require,module,exports){
// https://gist.github.com/colingourlay/7209131
/**
 * Fetches and inserts a script into the page before the first
 * pre-existing script element, and optionally calls a callback
 * on completion.
 *
 * [TODO] Make this a module of its own so it can be used elsewhere.
 *
 * @param  {String}   src      source of the script
 * @param  {Function} callback (optional) onload callback
 */
var getScript = function (src, callback) {
    var el = document.createElement('script');

    el.type = 'text/javascript';
    el.async = false;
    el.src = src;

    /**
     * Ensures callbacks work on older browsers by continuously
     * checking the readyState of the request. This is defined once
     * and reused on subsequeent calls to getScript.
     *
     * @param  {Element}   el      script element
     * @param  {Function} callback onload callback
     */
    getScript.ieCallback = getScript.ieCallback || function (el, callback) {
        if (el.readyState === 'loaded' || el.readyState === 'complete') {
            callback();
        } else {
            setTimeout(function () { getScript.ieCallback(el, callback); }, 100);
        }
    };

    if (typeof callback === 'function') {
        if (typeof el.addEventListener !== 'undefined') {
            el.addEventListener('load', callback, false);
        } else {
            el.onreadystatechange = function () {
                el.onreadystatechange = null;
                getScript.ieCallback(el, callback);
            };
        }
    }

    // This is defined once and reused on subsequeent calls to getScript
    getScript.firstScriptEl = getScript.firstScriptEl || document.getElementsByTagName('script')[0];
    getScript.firstScriptEl.parentNode.insertBefore(el, getScript.firstScriptEl);
};
module.exports = getScript;

},{}]},{},[4]);