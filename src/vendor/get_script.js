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
