!function a(b,c,d){function e(g,h){if(!c[g]){if(!b[g]){var i="function"==typeof require&&require;if(!h&&i)return i(g,!0);if(f)return f(g,!0);throw new Error("Cannot find module '"+g+"'")}var j=c[g]={exports:{}};b[g][0].call(j.exports,function(a){var c=b[g][1][a];return e(c?c:a)},j,j.exports,a,b,c,d)}return c[g].exports}for(var f="function"==typeof require&&require,g=0;g<d.length;g++)e(d[g]);return e}({1:[function(a,b){var c=Object.prototype.toString;b.exports=function(a){switch(c.call(a)){case"[object Function]":return"function";case"[object Date]":return"date";case"[object RegExp]":return"regexp";case"[object Arguments]":return"arguments";case"[object Array]":return"array";case"[object String]":return"string"}if("object"==typeof a&&a&&"number"==typeof a.length)try{if("function"==typeof a.callee)return"arguments"}catch(b){if(b instanceof TypeError)return"arguments"}return null===a?"null":void 0===a?"undefined":a&&1===a.nodeType?"element":a===Object(a)?"object":typeof a}},{}],2:[function(a,b,c){var d,e,f,g,h;d="https://www.cine.io/api/1/-",g={},h=function(a,b,c){return g[a]?setTimeout(function(){return c(null,g[a])}):f({url:a,dataType:"jsonp",success:function(b){return g[a]=b,c(null,b)},error:function(){return c(b)}}),null},c.getStreamDetails=function(a,b){var c,f;return f=""+d+"/stream?publicKey="+e.config.publicKey+"&id="+a,c="Could not fetch stream "+a,h(f,c,b)},c.nearestServer=function(a){var b,c;return c=""+d+"/nearest-server?default=ok",b="Could not fetch nearest server",h(c,b,a)},c.getStreamRecordings=function(a,b){var c,f;return f=""+d+"/stream/recordings?publicKey="+e.config.publicKey+"&id="+a,c="Could not fetch stream recordings for "+a,h(f,c,b)},c._clear=function(){return g={}},e=a("./main"),f=a("./vendor/ajax")},{"./main":4,"./vendor/ajax":7}],3:[function(a,b){var c,d;d=null,c=function(){return d||navigator},b.exports=function(){var a;try{if(new ActiveXObject("ShockwaveFlash.ShockwaveFlash"))return!0}catch(b){if(a=b,"undefined"==typeof c())return!1;if(!c().mimeTypes)return!1;if(void 0===c().mimeTypes["application/x-shockwave-flash"])return!1;if(c().mimeTypes["application/x-shockwave-flash"].enabledPlugin)return!0}return!1},b.exports._injectNavigator=function(a){return d=a}},{}],4:[function(a,b){var c,d,e,f,g;g=function(){if(!d.config.publicKey)throw new Error("CineIO.init(CINE_IO_PUBLIC_KEY) has not been called.")},d={config:{},init:function(a,b){var c,e,f;if(!a)throw new Error("Public Key required");d.config.publicKey=a,f=[];for(c in b)e=b[c],f.push(d.config[c]=e);return f},reset:function(){return d.config={}},publish:function(a,b,c,d){if(null==d&&(d={}),g(),!a)throw new Error("Stream ID required.");if(!b)throw new Error("Password required.");if(!c)throw new Error("DOM node required.");return f["new"](a,b,c,d)},play:function(a,b,c){if(null==c&&(c={}),g(),!a)throw new Error("Stream ID required.");if(!b)throw new Error("DOM node required.");return e.live(a,b,c)},playRecording:function(a,b,c,d){if(null==d&&(d={}),g(),!a)throw new Error("Stream ID required.");if(!b)throw new Error("Recording name required.");if(!c)throw new Error("DOM node required.");return e.recording(a,b,c,d)},getStreamDetails:function(a,b){if(g(),!a)throw new Error("Stream ID required.");return c.getStreamDetails(a,b)},getStreamRecordings:function(a,b){if(g(),!a)throw new Error("Stream ID required.");return c.getStreamRecordings(a,b)}},"undefined"!=typeof window&&(window.CineIO=d),b.exports=d,e=a("./play_stream"),f=a("./publish_stream"),c=a("./api_bridge")},{"./api_bridge":2,"./play_stream":5,"./publish_stream":6}],5:[function(a,b,c){var d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s;p=!1,k=!1,s=[],e={stretching:"uniform",width:"100%",aspectratio:"16:9",primary:"flash",autostart:!0,metaData:!0,controls:!0,mute:!1,rtmp:{subscribe:!0}},o=function(){var a,b,c;for(p=!0,b=0,c=s.length;c>b;b++)a=s[b],a.call();return s.length=0},f=function(a){return s.push(a)},g=function(a){return p?a():k?f(a):(k=!0,j("//jwpsrv.com/library/sq8RfmIXEeOtdhIxOQfUww.js",o),f(a))},r=function(a,b){return Object.prototype.hasOwnProperty.call(a,b)?a[b]:e[b]},m=function(a,b,c){var d,e;return e={width:r(c,"width"),height:"100%",autoplay:r(c,"autostart"),controls:r(c,"controls"),mute:r(c,"mute"),src:a},d="<video src='"+e.src+"' height='"+e.height+"' "+(e.autoplay?"autoplay":void 0)+" "+(e.controls?"controls":void 0)+" "+(e.mute?"mute":void 0)+">",document.getElementById(b).innerHTML=d},q=function(a,b,c,d){var e,f;return f=function(){return h()?void 0:m(b,c,d)},jwplayer.key=CineIO.config.jwPlayerKey,e={file:a,stretching:r(d,"stretching"),width:r(d,"width"),aspectratio:r(d,"aspectratio"),primary:r(d,"primary"),autostart:r(d,"autostart"),metaData:r(d,"metaData"),mute:r(d,"mute"),rtmp:r(d,"rtmp"),controlbar:r(d,"controls")},console.log("playing",e),jwplayer(c).setup(e),r(d,"controls")||jwplayer().setControls(!1),jwplayer().onReady(f),jwplayer().onSetupError(f)},l=function(a,b,c){return d.getStreamDetails(a,function(a,d){return console.log("streaming",d),q(d.play.rtmp,d.play.hls,b,c)})},i=function(a,b){var c,d,e,f;for(d=null,e=0,f=a.length;f>e;e++)if(c=a[e],c.name===b)return c.url},n=function(a,b,c,e){return d.getStreamRecordings(a,function(a,d){var f;if(f=i(d,b),!f)throw new Error("Recording not found");return e.primary=null,q(f,f,c,e)})},c.live=function(a,b,c){return g(function(){return l(a,b,c)})},c.recording=function(a,b,c,d){return g(function(){return n(a,b,c,d)})},j=a("./vendor/get_script"),h=a("./flash_detect"),d=a("./api_bridge")},{"./api_bridge":2,"./flash_detect":3,"./vendor/get_script":8}],6:[function(a,b,c){var d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x=[].slice;u=!1,q=!1,p=!1,w={},e="rtmp://publish-west.cine.io/live",f="Publisher",g="//cdn.cine.io/publisher.swf",r=function(){},i={serverURL:null,streamName:null,streamKey:null,audioCodec:"NellyMoser",streamWidth:720,streamHeight:404,streamFPS:15,keyFrameInterval:null,intervalSecs:10,bandwidth:1500,videoQuality:90},o=function(a,b){var c,d,e,h,j,k,l,m,n,o;return m="11.4.0",o="playerProductInstall.swf",e={},j={},c={},j.allowscriptaccess="always",j.allowfullscreen="true",j.wmode="transparent",c.id=a,c.name=f,c.align="middle",d=document.getElementById(a).offsetWidth,l=b.streamWidth||i.streamWidth,k=b.streamHeight||i.streamHeight,h=d/(l/k),n=""+window.location.protocol+g,swfobject.embedSWF(n,a,"100%",h,m,o,e,j,c,function(b){var c;return b.success?(c=function(){return b.ref.setOptions({jsLogFunction:"_jsLogFunction",jsEmitFunction:"_publisherEmit"}),t(a)},setTimeout(c,1e3)):void 0})},t=function(a){var b,c,d,e;for(console.log("publisher is ready!!!"),u=!0,e=w[a],c=0,d=e.length;d>c;c++)b=e[c],b.call();return delete w[a]},j=function(a,b,c){return w[a]||(w[a]=[]),w[a].push(function(){return console.log("HERE I AM"),m(a,b,c)})},k=function(a){var b;return b=document.getElementById(a),b&&b.data===window.location.protocol+g?b:null},v=function(a,b){return function(){return p=!0,o(a,b)}},s=function(a){return null!=w[a]},m=function(a,b,c){var d;return(d=k(a))?c(d):s(a)?j(a,b,c):(j(a,b,c),p?o(a,b):n("//ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js",v(a,b,c)))},l=function(a,b){return""+a.streamName+"?"+b+"&adbe-live-event="+a.streamName},h=function(){function a(a,b,c,d){this.streamId=a,this.password=b,this.domNode=c,this.publishOptions=d,this._ensureLoaded()}return a.prototype.start=function(){return console.log("loading publisher"),this._ensureLoaded(function(a){return function(b){return console.log("fetching stream",b),d.getStreamDetails(a.streamId,function(c,d){var e;return e=a._options(d),console.log("streamingggg!!",e),b.setOptions(e),b.start()})}}(this))},a.prototype.stop=function(){return this._ensureLoaded(function(a){return a.stop()})},a.prototype._options=function(a){var b,c;return c={serverURL:this.serverURL||e,streamName:l(a,this.password),audioCodec:this.publishOptions.audioCodec||i.audioCodec,streamWidth:this.publishOptions.streamWidth||i.streamWidth,streamHeight:this.publishOptions.streamHeight||i.streamHeight,streamFPS:this.publishOptions.streamFPS||i.streamFPS,bandwidth:this.publishOptions.bandwidth||1024*i.bandwidth*8,videoQuality:this.publishOptions.videoQuality||i.videoQuality},b=this.publishOptions.intervalSecs||i.intervalSecs,c.keyFrameInterval=c.streamFPS*b,c},a.prototype._ensureLoaded=function(a){return null==a&&(a=r),d.nearestServer(function(b){return function(c,d){return b.serverUrl=d.transcode,m(b.domNode,b.publishOptions,a)}}(this))},a}(),c["new"]=function(a,b,c,d){return new h(a,b,c,d)},window._publisherEmit=function(){var a,b;switch(a=arguments[0],b=2<=arguments.length?x.call(arguments,1):[],a){case"connect":case"disconnect":case"publish":case"status":case"error":return console.log.apply(console,b);default:return console.log.apply(console,b)}},window._jsLogFunction=function(a){return console.log("_jsLogFunction",a)},n=a("./vendor/get_script"),d=a("./api_bridge")},{"./api_bridge":2,"./vendor/get_script":8}],7:[function(a,b){function c(){return!0}function d(a,b,d,e){return a.global?c(b||x,d,e):void 0}function e(a){a.global&&0===D.active++&&d(a,null,"ajaxStart")}function f(a){a.global&&!--D.active&&d(a,null,"ajaxStop")}function g(a,b){var c=b.context;return b.beforeSend.call(c,a,b)===!1||d(b,c,"ajaxBeforeSend",[a,b])===!1?!1:void d(b,c,"ajaxSend",[a,b])}function h(a,b,c){var e=c.context,f="success";c.success.call(e,a,f,b),d(c,e,"ajaxSuccess",[b,c,a]),j(f,b,c)}function i(a,b,c,e){var f=e.context;e.error.call(f,c,b,a),d(e,f,"ajaxError",[c,e,a]),j(b,c,e)}function j(a,b,c){var e=c.context;c.complete.call(e,b,a),d(c,e,"ajaxComplete",[b,c]),f(c)}function k(){}function l(a){return a&&(a==B?"html":a==A?"json":y.test(a)?"script":z.test(a)&&"xml")||"text"}function m(a,b){return(a+"&"+b).replace(/[&?]{1,2}/,"?")}function n(a){"object"===r(a.data)&&(a.data=p(a.data)),!a.data||a.type&&"GET"!=a.type.toUpperCase()||(a.url=m(a.url,a.data))}function o(a,b,c,d){var e="array"===r(b);for(var f in b){var g=b[f];d&&(f=c?d:d+"["+(e?"":f)+"]"),!d&&e?a.add(g.name,g.value):(c?"array"===r(g):"object"===r(g))?o(a,g,c,f):a.add(f,g)}}function p(a,b){var c=[];return c.add=function(a,b){this.push(E(a)+"="+E(b))},o(c,a,b),c.join("&").replace("%20","+")}function q(a){var b=Array.prototype.slice;return b.call(arguments,1).forEach(function(b){for(u in b)void 0!==b[u]&&(a[u]=b[u])}),a}var r;try{r=a("type-of")}catch(s){var t=a;r=t("type")}var u,v,w=0,x=window.document,y=/^(?:text|application)\/javascript/i,z=/^(?:text|application)\/xml/i,A="application/json",B="text/html",C=/^\s*$/,D=b.exports=function(a){var b=q({},a||{});for(u in D.settings)void 0===b[u]&&(b[u]=D.settings[u]);e(b),b.crossDomain||(b.crossDomain=/^([\w-]+:)?\/\/([^\/]+)/.test(b.url)&&RegExp.$2!=window.location.host);var c=b.dataType,d=/=\?/.test(b.url);if("jsonp"==c||d)return d||(b.url=m(b.url,"callback=?")),D.JSONP(b);b.url||(b.url=window.location.toString()),n(b);var f,j=b.accepts[c],o={},p=/^([\w-]+:)\/\//.test(b.url)?RegExp.$1:window.location.protocol,r=D.settings.xhr();b.crossDomain||(o["X-Requested-With"]="XMLHttpRequest"),j&&(o.Accept=j,j.indexOf(",")>-1&&(j=j.split(",",2)[0]),r.overrideMimeType&&r.overrideMimeType(j)),(b.contentType||b.data&&"GET"!=b.type.toUpperCase())&&(o["Content-Type"]=b.contentType||"application/x-www-form-urlencoded"),b.headers=q(o,b.headers||{}),r.onreadystatechange=function(){if(4==r.readyState){clearTimeout(f);var a,d=!1;if(r.status>=200&&r.status<300||304==r.status||0==r.status&&"file:"==p){c=c||l(r.getResponseHeader("content-type")),a=r.responseText;try{"script"==c?(1,eval)(a):"xml"==c?a=r.responseXML:"json"==c&&(a=C.test(a)?null:JSON.parse(a))}catch(e){d=e}d?i(d,"parsererror",r,b):h(a,r,b)}else i(null,"error",r,b)}};var s="async"in b?b.async:!0;r.open(b.type,b.url,s);for(v in b.headers)r.setRequestHeader(v,b.headers[v]);return g(r,b)===!1?(r.abort(),!1):(b.timeout>0&&(f=setTimeout(function(){r.onreadystatechange=k,r.abort(),i(null,"timeout",r,b)},b.timeout)),r.send(b.data?b.data:null),r)};D.active=0,D.JSONP=function(a){if(!("type"in a))return D(a);var b,c="jsonp"+ ++w,d=x.createElement("script"),e=function(){c in window&&(window[c]=k),j("abort",f,a)},f={abort:e},g=x.getElementsByTagName("head")[0]||x.documentElement;return a.error&&(d.onerror=function(){f.abort(),a.error()}),window[c]=function(d){clearTimeout(b),delete window[c],h(d,f,a)},n(a),d.src=a.url.replace(/=\?/,"="+c),g.insertBefore(d,g.firstChild),a.timeout>0&&(b=setTimeout(function(){f.abort(),j("timeout",f,a)},a.timeout)),f},D.settings={type:"GET",beforeSend:k,success:k,error:k,complete:k,context:null,global:!0,xhr:function(){return new window.XMLHttpRequest},accepts:{script:"text/javascript, application/javascript",json:A,xml:"application/xml, text/xml",html:B,text:"text/plain"},crossDomain:!1,timeout:0},D.get=function(a,b){return D({url:a,success:b})},D.post=function(a,b,c,d){return"function"===r(b)&&(d=d||c,c=b,b=null),D({type:"POST",url:a,data:b,success:c,dataType:d})},D.getJSON=function(a,b){return D({url:a,success:b,dataType:"json"})};var E=encodeURIComponent},{"type-of":1}],8:[function(a,b){var c=function(a,b){var d=document.createElement("script");d.type="text/javascript",d.async=!1,d.src=a,c.ieCallback=c.ieCallback||function(a,b){"loaded"===a.readyState||"complete"===a.readyState?b():setTimeout(function(){c.ieCallback(a,b)},100)},"function"==typeof b&&("undefined"!=typeof d.addEventListener?d.addEventListener("load",b,!1):d.onreadystatechange=function(){d.onreadystatechange=null,c.ieCallback(d,b)}),c.firstScriptEl=c.firstScriptEl||document.getElementsByTagName("script")[0],c.firstScriptEl.parentNode.insertBefore(d,c.firstScriptEl)};b.exports=c},{}]},{},[4]);