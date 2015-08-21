// require sdk api module
const data = require("sdk/self").data,
      tabs = require("sdk/tabs"),
      windows = require("sdk/windows").browserWindows,
      urlMod = require("sdk/url"),
      request = require("sdk/request").Request,
      storage = require("sdk/simple-storage").storage,
      { ActionButton } = require('sdk/ui/button/action'),
      pageMod = require("sdk/page-mod"),
      prefs = require('sdk/simple-prefs');

// Initialize variables
var theTimer = {
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

// Button for opening add-on local page.
// In local page, users can check histories.
var openButton = ActionButton({
    id: "time-recorder-button",
    label: "time-recorder-button",
    icon: data.url("nomrat.png"),
    onClick: function(){
        require("sdk/tabs").open({
            url: data.url("history_list.html"),
            inBackground: true
        });
    }
});

// store history JSON to add on storage (simple-storage)
var storeHistory = function(history){
    if (!storage.histories) { storage.histories = []; }
    storage.histories.push(history);
}

// fetch CSRF-Token from DTB
var fetchCSRFToken = new Promise(function(resolve, reject){
    request({
        url: prefs.prefs["DTBURL"],
        onComplete: function(response){
            var matchArray = response.text.match(/<meta content="(.*)" name="csrf-token" \/>/);
            if( matchArray ){
                resolve(matchArray[1]);
            }else{
                reject(response.text);
            }
        }
    }).get();
});

// post history json to DTB with CSRF token
var postHistory = function(historyJSON) {
    if (historyJSON["is_posted"]) {return historyJSON;}
    // the following function runs when fetchCSRFToken exec "resolve"
    // expect ["#{csrf-token}"] as values
    Promise.all([fetchCSRFToken]).then(function(values) {
        delete historyJSON["is_posted"]
        request({
            headers: {
                "X-CSRF-Token": values[0]
            },
            url: prefs.prefs["DTBURL"] + "/unified_histories.json",
            content: {unified_history : historyJSON},
            contentType: "application/x-www-form-urlencoded", //TODO: send request with "application/json"
            onComplete: function(response){
                if (response.status == 201) {
                    historyJSON["is_posted"] = true;
                } else {
                    historyJSON["is_posted"] = false;
                }
            }
        }).post();
    // the following function runs when fetchCSRFToken exec "reject"
    }, function(responseText) {
        console.log("Fail to fetch CSRF token: " + responseText);
    });
    return historyJSON;
}

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
        thumbnail    : theTimer.thumbnail,
        is_posted    : false
    };
    storeHistory(historyJSON);
    storage.histories = storage.histories.map(postHistory);
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

// main functions
exports.main = function() {
    // set event listeners for recording reference time
    /// events that turn timing off
    tabs.on('deactivate', clock_off );
    windows.on('deactivate', function() {
        theTimer.windowActive = false;
        clock_off();
    });
    windows.on('close', clock_off );

    /// events that turn timing on
    windows.on('activate', function() {
        theTimer.windowActive = true;
        clock_on();
    });
    tabs.on('activate', clock_on );

    //// "pageshow" listener for moving back/forward in browser history
    tabs.on('pageshow', clock_on );

    // Modify page in Record List page.
    // Dynamically add a row to history table
    pageMod.PageMod({
        include: data.url("history_list.html"),
        contentScriptFile: "./history_list.js",
        onAttach: function(worker) {
            worker.port.emit("getHistories", storage.histories);
        }
    });
}
