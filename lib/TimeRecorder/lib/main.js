// Initialize variables
var tabs = require("sdk/tabs"),
    windows = require("sdk/windows").browserWindows,
    urlMod = require("sdk/url"),
    request = require("sdk/request").Request,
    theTimer = {
        isOn : false,
        title : "",
        url : "",
        thumbnail : "",
        startStamp : null,
        windowActive : true,
        timeout : null,         // the timeout counter for idle user
        timeoutOneSecs : 30000,
        timeoutTwoSecs : 30000,
        timeoutBothSecs : 60000 // = timeoutOneSecs + timeoutTwoSecs
    };

var DTBURL = "http://localhost:3000";
var createHistoryURL = DTBURL + "/unified_histories.json";

// Ajax 送信前にX-CSRF-Tokenを埋込む
var fetchCSRFToken = new Promise(function(resolve, reject){
    request({
        url: DTBURL,
        onComplete: function (response) {
            var matchArray = response.text.match(/<meta content="(.*)" name="csrf-token" \/>/);
            if( matchArray ){
                resolve(matchArray[1]);
            }else{
                reject(response.text);
            }
        }
    }).get();
});

// stop clock
var clock_off = function() {
    if (!theTimer.isOn) {
        return;  // recording is not started
    }
    var historyJSON = {
        path         : theTimer.url,
        title        : theTimer.title,
        type         : "WebHistory",
        r_path       : "",
        start_time   : theTimer.startStamp,
        end_time     : (new Date()).toString(),
        thumbnail    : theTimer.thumbnail
    };
    Promise.all([fetchCSRFToken]).then(function(values) {
        // expect ["#{csrf-token}"]
        request({
            headers: {
                "X-CSRF-Token": values[0]
            },
            url: createHistoryURL,
            content: {unified_history : historyJSON},
            contentType: "application/x-www-form-urlencoded", //TODO: send request with "application/json"
            onComplete: function (response) {
                console.log("Status: " + response.status)
            }
        }).post();
    });
    theTimer.isOn = false;
};

// start clock
var clock_on = function() {
    if (theTimer.isOn && theTimer.url == tabs.activeTab.url) {
        return;  // continue recording
    }
    clock_off(); // record previous page
    theTimer.title = tabs.activeTab.title;
    theTimer.url = tabs.activeTab.url;
    theTimer.thumbnail = tabs.activeTab.getThumbnail();
    theTimer.startStamp = (new Date()).toString();
    theTimer.isOn = true;
};

// events that turn timing off
tabs.on('deactivate', clock_off );

windows.on('deactivate', function() {
    theTimer.windowActive = false;
    clock_off();
});

windows.on('close', clock_off );

// events that turn timing on
windows.on('activate', function() {
    theTimer.windowActive = true;
    clock_on();
});

tabs.on('activate', clock_on );

// "pageshow" listener for moving back/forward in browser history
tabs.on('pageshow', clock_on );
