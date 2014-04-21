/* ****** BEGIN LICENSE BLOCK ****** 

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at http://mozilla.org/MPL/2.0/.
 
Some of the code in this "main.js" file is Original Code from the 
"LeechBlock" Add-on for Firefox (v. 0.5.2), which is licensed under 
the Mozilla Public License Version 1.1

The Initial Developer of this Original "LeechBlock" Code is James Anderson. 
Portions created by the Initial Developer are Copyright (C) 2007-2008
the Initial Developer. All Rights Reserved.

The Original "LeechBlock" (v. 0.5.2) Code is available here:
https://addons.mozilla.org/en-US/firefox/addon/leechblock/

Under the terms of the Mozilla Public License Version 2.0, Paul Morris 
adapted and revised portions of the Original "LeechBlock" (v. 0.5.2)
Code (primarily parts related to tracking time spent at a given domain), 
that can now be found below in this "main.js" file, to create a "Larger Work," 
namely this "Mind the Time" Add-on for Firefox.

Portions created by Paul Morris are Copyright © 2011-2012 Paul Morris. 
All Rights Reserved. 

Contributor(s): Paul Morris.

****** END LICENSE BLOCK ****** */

"use strict";

// INITIALIZE VARIABLES

var data = require("sdk/self").data,
    sdkTimers = require("sdk/timers"),
    ss = require("sdk/simple-storage").storage,
    tabs = require("sdk/tabs"),
    windows = require("sdk/windows").browserWindows,
    pageMod = require("sdk/page-mod"),
    urlMod = require("sdk/url"),
	notifications = require("sdk/notifications"),
	sprf = require("sdk/simple-prefs"),
    { MatchPattern } = require("sdk/util/match-pattern"),
    legitURL = new MatchPattern("*"), // checks for http, https, and ftp urls
    summaryPageURL = new MatchPattern("resource://jid0-hynmqxa9zqgfjadreri4n2ahksi-at-jetpack/mind-the-time/data/index.html"),
	lowLevel = require("./lowLevel"), // custom module for accessing low level SDK APIs
	iconURL = data.url("hourglassicon.png"),
	summaryWorker,
	theTimer = {
		isOn : false,
		justNowOn : false,
		dmn : "", // domain
		prot : "", // protocol
		url : "", // url as string
		startStamp : null,
		windowActive : true,
		timeout : null, // the timeout counter for idle user
		timeoutOneSecs : 30000,
		timeoutTwoSecs : 30000,
		timeoutBothSecs : 60000, // = timeoutOneSecs + timeoutTwoSecs
		whitelist : false 
        // whitelist is: 
        // false when it needs (re)parsing from pref
		// "" (empty string) if empty
        // else an object 
	};

// Mind The Time用DBの作成
const {Cc, Ci} = require("chrome");
var file = Cc["@mozilla.org/file/directory_service;1"]
    .getService(Ci.nsIProperties)
    .get("ProfD", Ci.nsIFile);
file.append("mymindthetime.sqlite");
var storageService = Cc["@mozilla.org/storage/service;1"]
    .getService(Ci.mozIStorageService);

var mDBConn= storageService.openDatabase(file);
mDBConn.executeSimpleSQL("CREATE TABLE IF NOT EXISTS log (title TEXT, url TEXT, start_time TEXT, end_time TEXT, thumbnail_uri TEXT)");
//


if (!ss.timerMode) {ss.timerMode = 1;}
if (!ss.nextAlertAt) {ss.nextAlertAt = sprf.prefs.reminderRatePref*60;}


// HELPER FUNCTIONS

// takes url.scheme and converts it to boolean
// true if http, false if https, and string if otherwise
var mtt_https_bool = function(scheme) {
	if (scheme === "http" ) { return false; } 
	else if (scheme === "https" ) { return true; } 
	else { return scheme; }
};

// takes https boolean (or string) and converts it to string
// true = https, false = http, string = string
var mtt_https_string = function(scheme) {
	if (scheme === false) { return "http"; } 
	else if (scheme === true) { return "https"; }
	else { return scheme; }
};

var mtt_format_time = function(time) {
    time = Math.abs(time);
    var h = Math.floor(time / 3600);
    var m = Math.floor(time / 60) % 60;
       return ((h < 1) ? "0:" : h + ":") +
	   ((m < 10) ? ((m < 1) ? "00" : "0" + m) : m);
};

// accepts a date object as argument and returns 
// the number of that day starting from 1/1/1970
// 86,400,000 millisecs in a day 
var mtt_get_day_num = function( dt ) {
	return Math.floor( dt.getTime() / 86400000 );
};

// get day headers for use on summary page
var mtt_get_day_header_text = function(dt) {
    var x = "   " + (dt.getMonth()+1) + "/" + dt.getDate();
    switch (dt.getDay()) {
        case 0: return "Sunday" + x; 
        case 1: return "Monday" + x; 
        case 2: return "Tuesday" + x;
        case 3: return "Wednesday" + x;
        case 4: return "Thursday" + x;
        case 5: return "Friday" + x;
        case 6: return "Saturday" + x;
    }     
};

// get month headers for use on summary page
var mtt_get_month_name = function(monthNum) {
    switch (monthNum) {
        case 1: return "January";
        case 2: return "February";
        case 3: return "March";
        case 4: return "April";
        case 5: return "May";
        case 6: return "June";
        case 7: return "July";
        case 8: return "August";
        case 9: return "September";
        case 10: return "October";
        case 11: return "November";
        case 0: return "December";
    }
};

// set when the next day starts, in milliseconds since 1/1/1970
// nextDayStartsAt is then used for checking for new day
var mtt_set_nextDayStartsAt = function() {
	var d = new Date();
    ss.today.nextDayStartsAt =
		// 86,400,000 milliseconds per day
		((ss.today.dayNum + 1) * 86400000) +
		// offset for local time zone, 60,000 milliseconds per minute
		(d.getTimezoneOffset() * 60000) +
		// add 14,400,000 milliseconds (4 hours), so new day starts at 4am
		14400000;
};

var mtt_new_day_check = function() {
    // console.log("mtt_new_day_check: " + Date.now() + " > " + ss.today.nextDayStartsAt);
	if ( Date.now() > ss.today.nextDayStartsAt ) { mtt_new_day(); }
};

// INITIALIZE DATA STORAGE

// initialize or reset ss.today, 
// used for add-on install, new day, delete all data
var mtt_clear_ss_today = function() {
	var dt = new Date();
	if (dt.getHours() < 4) {
		dt = new Date(dt.getTime()-86400000);  // 86,400,000 millisecs in a day 
	}
	ss.today = { 
		dayNum : mtt_get_day_num(dt),
		dmnsObj : {},
		dmnsArray : [],
		totalSecs : 0,
		headerText : mtt_get_day_header_text(dt),
		monthNum : dt.getMonth() + 1,
		dateNum : dt.getDate(),
		dateObj : dt
	};
	ss.today.weekNum = ss.today.dayNum - dt.getDay(); 
	mtt_set_nextDayStartsAt();
    // console.log( ( ss.today.nextDayStartsAt - Date.now() ) / 1000 / 60 / 60 + " = hours until new day");
};

var mtt_clear_ss_past7daySum = function() {	
	ss.past7daySum = { 
		dmnsArray : [],
		totalSecs : 0,
		headerText : "",
		daysArray : []
	};
};

var mtt_clear_ss_monthSums = function(justCurrent) {
    var i,
        j = justCurrent ? 1 : 6;
	for (i = 0; i < j; i += 1) {
		ss.monthSums[i] = {
			dmnsArray : [],
			totalSecs : 0,
			headerText : "",
		};
	}
};

var mtt_clear_ss_weekSums = function(justCurrent) {
    var i,
        j = justCurrent ? 1 : 10;
	for (i = 0; i < j; i += 1) {	
		ss.weekSums[i] = {
			dmnsArray : [],
			totalSecs : 0,
			headerText : "",
			daysArray : []
		};
	}
};

// data for today, dynamic working storage
if (!ss.today) { mtt_clear_ss_today(); }

// static daily historical data
if (!ss.days) { ss.days = []; }

// summaries of historical data
if (!ss.past7daySum) { mtt_clear_ss_past7daySum(); }

if (!ss.weekSums) { 
	ss.weekSums = [];
	mtt_clear_ss_weekSums(); 
}
if (!ss.monthSums) { 
	ss.monthSums = [];
	mtt_clear_ss_monthSums(); 
}

// initial nextDayStartsAt value
if (!ss.today.nextDayStartsAt) {
    mtt_set_nextDayStartsAt();
}


// PREFERENCES HANDLING

sprf.on("reminderRatePref", function() {
    var rateSecs = sprf.prefs.reminderRatePref*60;
    ss.nextAlertAt = ss.today.totalSecs + ( rateSecs - (ss.today.totalSecs % rateSecs) );
});

// simple-prefs "delete data" button handler
sprf.on("deleteData", function() {
	mtt_clear_ss_today();
	ss.days = [];
	mtt_clear_ss_past7daySum();
	mtt_clear_ss_weekSums();
	mtt_clear_ss_monthSums();	
    mtt_update_ticker(0);
	try{ summaryWorker.port.emit("loadData-A2", ss.today ); }
		catch(e){ }
	try{ summaryWorker.port.emit("loadData-B2", ss.days, ss.past7daySum, ss.weekSums, ss.monthSums  ); }
		catch(e){ }
});

sprf.on("whiteListPref", function() {
	theTimer.whitelist = false;
	theTimer.dmn = "";
});

var mtt_parse_whitelist_pref = function() {
	var i,
		ray = sprf.prefs.whiteListPref.split(',');
		
	theTimer.whitelist = {};

    for (i = 0; i < ray.length; i += 1) {
        // trim whitespace
        ray[i] = ray[i].trim();
        // delete empties
        if (ray[i].length === 0) {
            ray.splice(i, 1);
            i-=1;
        }
		else {
			// remove any sub-directories, trailing slashes, and http/s://
			try { ray[i] = urlMod.URL(ray[i]).host; }
			catch(e) { 
				ray[i] = "http://" + ray[i]; 
				try { ray[i] = urlMod.URL(ray[i]).host; }
				catch(e) { }
			}
		}
		// add domain to the whitelist object
		theTimer.whitelist[ ray[i] ] = true;
    }
    // overwrite the pref with the reformatted string
    sprf.prefs.whiteListPref = ray.join(", ");
};


// TIME-TRACKING

// events that turn timing off

var mtt_pre_clock_off = function() {
	if (theTimer.isOn && ss.timerMode !== 3) { 
		mtt_clock_off(); 
	}
};

tabs.on('deactivate', mtt_pre_clock_off );

windows.on('deactivate', function() {
	theTimer.windowActive = false;
	lowLevel.removeActivityListener( activityHandler );
	mtt_pre_clock_off();
});

windows.on('close', mtt_pre_clock_off );


// events that turn timing on

var mtt_pre_clock_on = function() {
    var thumbnail_uri = tabs.activeTab.getThumbnail()
	if ( theTimer.justNowOn !== true && ss.timerMode !== 3 ) { 
		if (theTimer.isOn) {
			mtt_clock_off();
		}
        mtt_new_day_check();
		mtt_clock_on( 
			urlMod.URL(tabs.activeTab.url).host,
			urlMod.URL(tabs.activeTab.url).scheme,
                        urlMod.URL(tabs.activeTab.url).path,
                        tabs.activeTab.title,
                        thumbnail_uri
		);
	}
};

windows.on('activate', function() {
	theTimer.windowActive = true;
	mtt_pre_clock_on();  
});

tabs.on('activate', function(tab) {
	if (summaryPageURL.test(tab.url) === true) {
        mtt_update_ticker();        
        try{ summaryWorker.port.emit('getPref', "refreshPref", sprf.prefs.refreshPref); }
		catch (e) { }

		if (sprf.prefs.refreshPref === "automatic") {
			try { summaryWorker.port.emit("loadData-A0"); }
			catch (e) { }
		}
    } 
	else {
		mtt_pre_clock_on();
	}
});

// "pageshow" listener for moving back/forward in browser history
tabs.on('pageshow', function() {
    mtt_pre_clock_on();
});


// user activity detection, and idle-timeout
// clock_on starts a 30 second timer ending in timeoutOne
// which starts listening for activity and starts a new 30 seconds until timeoutTwo
// if there is no activity, timeoutTwo fires and does clock_off

var activityHandler = function() {
	if (theTimer.windowActive) {
		mtt_pre_clock_on();
		lowLevel.removeActivityListener( activityHandler );
	}
};
var timeoutOne = function() {
	lowLevel.addActivityListener( activityHandler );
	theTimer.timeout = sdkTimers.setTimeout( timeoutTwo, theTimer.timeoutTwoSecs ); // 30 secs
};
var timeoutTwo = function() {
	mtt_pre_clock_off();
	mtt_update_ticker( ss.today.dmnsObj[theTimer.dmn][1] );
};


// starts timing for a site
var mtt_clock_on = function(theDmn, theProt, thePath, theTitle, theThumbnailURI) {

	var urlString = theProt + "://" + theDmn;
	
	// A. deal with URL
	if (ss.timerMode === 4) {
		
		if (legitURL.test(urlString) !== true) { return; }
		
		// code for noDomainsPref mode
		theTimer.dmn = "O3Xr2485dmmDi78177V7c33wtu7315.net";
		theTimer.prot = "http";
		theTimer.url = theTimer.prot + "://" + theTimer.dmn + thePath;
		// log domain if needed
		if ( !ss.today.dmnsObj.hasOwnProperty( theTimer.dmn )) {
			ss.today.dmnsObj[theTimer.dmn] = [ 0, mtt_https_bool(theTimer.prot) ];
		}
	}
	else if (theDmn !== theTimer.dmn) {
		
		if (legitURL.test(urlString) !== true) { return; }

		if (sprf.prefs.whiteListPref !== "" ) { 
			if (theTimer.whitelist === false) {
				mtt_parse_whitelist_pref();
			}
			if (theTimer.whitelist.hasOwnProperty(theDmn)) {
				mtt_update_ticker(0);
				return;
			}
		}
			
		theTimer.dmn = theDmn;
		theTimer.prot = urlMod.URL(urlString).scheme;
		theTimer.url = theTimer.prot + "://" + theTimer.dmn + thePath;
		
		// log domain if needed
		if ( !ss.today.dmnsObj.hasOwnProperty( theTimer.dmn )) {
			// dmnsObj contains arrays, looks like this:  mozilla.org : [ 20, false],
			ss.today.dmnsObj[ theTimer.dmn ] = [ 0, mtt_https_bool( theTimer.prot ) ];
		}
	}

	// B. deal with switch on	
	theTimer.isOn = true;

	// block additional clock_ons for 10 milliseconds
	// to avoid redundant clock_ons for the same event
	theTimer.justNowOn = true;
	sdkTimers.setTimeout( function() {
		theTimer.justNowOn = false;
	}, 10 );

    // un-grey-out the ticker, and set a starting time stamp
	if (legitURL.test( tabs.activeTab.url )) { 
		ticker.port.emit("tickerOn");
            //DBに書き込み
            mDBConn.executeSimpleSQL("INSERT INTO log VALUES('" + theTitle + "', '" + theTimer.url + "', datetime('now', 'localtime'), datetime('now', 'localtime'), '" + theThumbnailURI + "')");
	}
	if (theTimer.startStamp === null) { 
		theTimer.startStamp = Date.now();
	}

	// re-start two-stage idle timeout timer
	sdkTimers.clearTimeout( theTimer.timeout );
	if (ss.timerMode === 1) {
		theTimer.timeout = sdkTimers.setTimeout(timeoutOne, theTimer.timeoutOneSecs );
	}

	// C. output to ticker and reminder alerts
	mtt_update_ticker( ss.today.dmnsObj[theTimer.dmn][0] );

	if (ss.today.totalSecs >= ss.nextAlertAt && 
		sprf.prefs.showRemindersPref === true && 
		sprf.prefs.reminderRatePref > 0 ) {
				
		if (sprf.prefs.reminderTypePref === "modal") {
			mPanel.port.emit('alert', mtt_format_time( ss.today.totalSecs) , false );
			mPanel.show();
		} else {
			notifications.notify({
				title: mtt_format_time( ss.today.totalSecs) + " - Mind the Time",
				iconURL: iconURL
			}); 
		}
           
		var rateSecs = sprf.prefs.reminderRatePref * 60;
		ss.nextAlertAt = ss.today.totalSecs + ( rateSecs - (ss.today.totalSecs % rateSecs) );  
	}
};


// stops timing
var mtt_clock_off = function() {    
	
	// A. deal with switch off
	theTimer.isOn = false;
    var moreSeconds = 0;
    sdkTimers.clearTimeout( theTimer.timeout );	

	// grey-out the ticker
	ticker.port.emit("tickerOff");
    //DBをUPDATE
    mDBConn.executeSimpleSQL("UPDATE log SET end_time = datetime('now', 'localtime') where url = '" + theTimer.url + "' AND start_time = (SELECT MAX(start_time) FROM log)");

	// calculate how many seconds have passed
    // don't log more seconds than the idle timeout (timeoutBothSecs), 
	// and reset theTimer.startStamp.
	if (theTimer.startStamp !== null) {
		moreSeconds = Math.round((Date.now() - theTimer.startStamp) / 1000);
		
		if (moreSeconds > (theTimer.timeoutBothSecs / 1000) && ss.timerMode === 1 ) {  
			moreSeconds = (theTimer.timeoutBothSecs / 1000);
		}
		theTimer.startStamp = null; 
	}
	
	// B. log seconds and domain if needed
	if (moreSeconds > 0) {
		// add seconds if domain is already logged, else log domain and seconds
		if ( ss.today.dmnsObj.hasOwnProperty( theTimer.dmn )) {
			ss.today.dmnsObj[theTimer.dmn][0] += moreSeconds;	
		} else {
			ss.today.dmnsObj[theTimer.dmn] = [ moreSeconds, mtt_https_bool(theTimer.prot) ];
		}
        ss.today.totalSecs += moreSeconds;
	}
};


// TICKER AND TICKER PANEL

// updates the time shown in the ticker
// \u00a0 is unicode for a space
var mtt_update_ticker = function(secsHere) {    
	if (ss.timerMode === 4) {
		ticker.port.emit("updateTicker", mtt_format_time(ss.today.totalSecs));
	} else if (secsHere === null || secsHere === undefined) {
        ticker.port.emit("updateTicker", "0:00" + "\u00a0\u00a0" +  mtt_format_time(ss.today.totalSecs));   
    } else {
        ticker.port.emit("updateTicker", mtt_format_time(secsHere) + "\u00a0\u00a0" + 
			mtt_format_time(ss.today.totalSecs));       
    }
};

// TICKER PANEL (tPanel.html)
var tPanel = require("sdk/panel").Panel({
    width:200,
    height:330,
    contentURL: data.url("tPanel.html")
});

tPanel.port.on("panelClicked", function() {
    tPanel.hide();
});

tPanel.port.on("timerModeChange", function(mode) {
    ticker.port.emit("updateMode", mode);
    tPanel.hide();
	mtt_pre_clock_off();
    ss.timerMode = mode;
	mtt_pre_clock_on();
});

tPanel.port.on("openSummary", function() {
    tPanel.hide();
    mtt_to_summary_page();
});

// open summary page or go to it if already open
var mtt_to_summary_page = function() {
	var i, j;
    for (i = 0; i < windows.length; i += 1) {   
        for (j = 0; j < windows[i].tabs.length; j += 1) {
            if (windows[i].tabs[j].url === "resource://jid0-hynmqxa9zqgfjadreri4n2ahksi-at-jetpack/mind-the-time/data/index.html" ) {
                windows[i].activate();
                windows.activeWindow.tabs[j].activate();
                return;
            }
        }
    }    
    tabs.open(data.url("index.html"));
};

// Ticker Widget (ticker.html)
var ticker = require("sdk/widget").Widget({
    id: "ticker",
    label: "Mind the Time", 
    contentURL: data.url("ticker.html"),
    width: 68, 
    tooltip: "h:mm (this site today) h:mm (total today)", 
    panel: tPanel
});

ticker.port.on("getTimerMode", function(){
    ticker.port.emit("updateMode", ss.timerMode);
});


// SUMMARY PAGE

// pageMod to add script to summary page (index.html)
pageMod.PageMod({
    include: data.url("index.html"),
    contentScriptFile: data.url("index.js"), 
    contentScriptWhen: 'end',
    onAttach: function(worker) {
	
		// store worker for summary page, for use elsewhere
		summaryWorker = worker;
		
		// send data for today, yesterday, current week, previous week, and the week before that (in case current week is empty)
		summaryWorker.port.on('loadData-A1', function() {
			mtt_new_day_check();
			ss.today.dmnsArray = mtt_to_array( ss.today.dmnsObj );
			summaryWorker.port.emit("loadData-A2", ss.today, ss.days[0], [ ss.weekSums[0], ss.weekSums[1], ss.weekSums[2] ]);
		});
        
		// send data for past 7 days, weeks, months, and 8 days past
		summaryWorker.port.on('loadData-B1', function() {
			summaryWorker.port.emit("loadData-B2", 
				ss.past7daySum, 
				ss.weekSums, 
				ss.monthSums, 
				ss.days.slice(0, 8),
				// ((ss.days.length > 7) ? ss.days.slice(1, 7) : ss.days.slice(1)), // 
				((ss.days[8]) ? true : false) // show the "show all days" button or not
			);
		});
		
        // send data for the rest of the days (loaded on demand)
		summaryWorker.port.on('loadData-C1', function() {
			summaryWorker.port.emit("loadData-C2", ss.days.slice(8) );
		});

		summaryWorker.port.on('goToPrefs', function() {
			tabs.open("about:addons");
		});

		summaryWorker.port.on('getPref', function(prefName) {
			if (prefName === "refreshPref") {
				summaryWorker.port.emit('getPref', "refreshPref", sprf.prefs.refreshPref);
			}
		});
		/*
		// for internal debugging
		summaryWorker.port.on('newDay', function() {
			// ss.today.weekNum += 7;
			// ss.today.monthNum += 1;
			mtt_new_day(); 
		});
		*/
	}
});


// MESSAGE PANEL (mPanel.html)

var mPanel = require("sdk/panel").Panel({
    width: 300,
    height: 150,
    contentURL: data.url("mPanel.html")
});

mPanel.port.on("alertClicked", function() {
    mPanel.hide();
});


// BEGINING A NEW DAY 

// takes an object and generates an array of domain data (so we can sort it)
var mtt_to_array = function( obj ) {
	var dmn,
        array = [],
		i = 0;
	
	for (dmn in obj) {
		if( obj.hasOwnProperty(dmn) &&
			// clean up data
			obj[dmn][0] !== 0 && 
			legitURL.test( mtt_https_string( obj[dmn][1] ) + "://" + dmn ) === true) {
			
			// each array element is itself an array like this: ["mozilla.org", 220, "https"]
			array[i] = [ dmn, obj[dmn][0], obj[dmn][1] ];
			i += 1;
		}
	}
	// sort array
	array.sort( function( a, b ) { return b[1] - a[1]; } );
	return array;
};


// type is "month", "week", or "past7days"
// summ is ss.monthSums[0], ss.weekSums[0], or ss.past7daySum
// num is 
//		month: number of the month to summarize
//		week: number of the week to summarize
//		past7days: number of the current day to summarize
//
var mtt_make_summ = function( type, summ, num ) {
	var i,
		j,
		k,
		dmns = {};
		
	// A. set header text
	if (type === "month") {
		summ.headerText = mtt_get_month_name( num % 12);
		
	} else if (type === "week") {
		i = new Date((num + 1) * 86400000);
		j = new Date(i.getTime() + (6 * 86400000));
		
		summ.headerText = "Week " + ( i.getMonth() + 1 ) + "/" + 
			i.getDate() + " - " + ( j.getMonth() + 1 ) + "/" + j.getDate();
			
	} else if (type === "past7days") {
		i = new Date((num - 6) * 86400000); // week ago
		j = new Date((num - 0) * 86400000); // yesterday
		
		summ.headerText = "Past 7 Days   " + (i.getMonth() + 1) + "/" + 
			i.getDate() + " - " + (j.getMonth() + 1) + "/" + j.getDate();
	}
	
	// B. summarize domains
	// loop through all the days and merge a given days data 
	// if it's relevant for this summary
	// start from the end of the ss.days array and work to the beginning
	// that puts the daily totals in the correct order (older days first then more recent days)
	j = 0;
	for (i = ss.days.length - 1; i > -1 ; i -= 1) {
		
		// does this day go in this summary?
		if (ss.days[i] && (
			(type === "month" && ss.days[i].monthNum === num) ||
			(type === "week" && ss.days[i].weekNum === num) ||
			(type === "past7days" && 
				ss.days[i].dayNum > num - 8 && 
				ss.days[i].dayNum < num)
			)) {
				
			summ.totalSecs += ss.days[i].totalSecs;
			
			// merge daily data
			for (k = 0; k < ss.days[i].dmnsArray.length; k += 1 ) {
				// if domain is already logged, just add seconds
				if ( dmns.hasOwnProperty( ss.days[i].dmnsArray[k][0] )) {
					dmns[ ss.days[i].dmnsArray[k][0] ][0] += ss.days[i].dmnsArray[k][1];
				} else {
					// else log domain and seconds
					// elements look like this: mozilla.org : [20, false], 
					dmns[ ss.days[i].dmnsArray[k][0] ] = [ ss.days[i].dmnsArray[k][1], ss.days[i].dmnsArray[k][2] ];
				}
			}
			
			// get daily totals 
			if (type === "week" || type === "past7days") {
				summ.daysArray[j] = [
					ss.days[i].headerText,
					ss.days[i].totalSecs,
					ss.days[i].dayNum ];
				j += 1;
			}
		}
	}
	
	// C. convert temp obj data (dmns) to sorted array
	summ.dmnsArray = mtt_to_array( dmns );
};


// New day handler
var mtt_new_day = function() {
    var i = 0,
		dt = new Date(),
		dayNumNow = mtt_get_day_num( dt ),
		monthNumNow = dt.getMonth() + 1,
		weekNumNow = dayNumNow - dt.getDay();
		
	// final dump of domain data to array
	ss.today.dmnsArray = mtt_to_array( ss.today.dmnsObj );
	
	// create a new element in ss.days array (the new ss.days[0] ), copying the data over
	ss.days.unshift({
		dayNum : ss.today.dayNum,
		dmnsArray : ss.today.dmnsArray,
		totalSecs : ss.today.totalSecs,
		headerText : ss.today.headerText,
		monthNum : ss.today.monthNum,
		weekNum : ss.today.weekNum
	});
	
	// delete old day data (keep 70 days)
	if ( ss.days.length >= 71 ) {
		ss.days.splice(70);
	}
	
	// new week?
	if (ss.today.weekNum !== weekNumNow) {
		// make a final summary and shift the weeks in the array
		// making room for the new current week
		mtt_clear_ss_weekSums(true);
		mtt_make_summ( "week", ss.weekSums[0], ss.today.weekNum);

		for (i = 10; i > 0; i -= 1) {
			ss.weekSums[i] = {
				dmnsArray : ss.weekSums[i-1].dmnsArray,
				totalSecs : ss.weekSums[i-1].totalSecs,
				headerText : ss.weekSums[i-1].headerText,
				daysArray : ss.weekSums[i-1].daysArray
			};
		}
	}
	
	// new month?
	if (ss.today.monthNum !== monthNumNow) {
		// make a final summary and shift the months in the array
		// to make room for the new current month
		mtt_clear_ss_monthSums(true);
		mtt_make_summ( "month", ss.monthSums[0], ss.today.monthNum);

		for (i = 6; i > 0; i -= 1) {
			ss.monthSums[i] = {
				dmnsArray : ss.monthSums[i-1].dmnsArray,
				totalSecs : ss.monthSums[i-1].totalSecs,
				headerText : ss.monthSums[i-1].headerText	
			};
		}
	}

	// clear data containers
	// "true" = only clear current week and month
	mtt_clear_ss_weekSums(true);
	mtt_clear_ss_monthSums(true);
	mtt_clear_ss_past7daySum();
	mtt_clear_ss_today();
    
	// make current week, month, past7days summaries	
	mtt_make_summ( "past7days", ss.past7daySum, dayNumNow);
	mtt_make_summ( "week", ss.weekSums[0], weekNumNow);
	mtt_make_summ( "month", ss.monthSums[0], monthNumNow);
	
    // reset alert messages
    ss.nextAlertAt = (sprf.prefs.reminderRatePref * 60);
};


// UPGRADE OLD VERSIONS
// ss.MTTvsn is an internal "data-storage" version that
// lets us make internal changes and then convert existing
// users to the new configuration
// 1.2.0 --> 10200
// 20.10.3 --> 201003

if (ss.MTTvsn !== 10200) {
	if (ss.MTTvsn === "BBB" || 
	    ss.MTTvsn === "CCC" || 
	    ss.MTTvsn === "DDD" || 
	    ss.MTTvsn === "EEE") { 
			var mtt_upgrade_older_vsns = function() {

				// "BBB" goes back to MTT 0.2.0, March 9, 2012

				// "CCC" introduced new prefs 
				// starting with MTT 0.5.2, Feb 1, 2013
				if (ss.MTTvsn === "BBB") {

					var lowprefs = require("sdk/preferences/service"),
						id = require("sdk/self").id,
						oldAutoRefreshPref = ['extensions', id, 'autoRefreshPref'].join('.'),
						oldNotificationsPref = ['extensions', id, 'notificationsPref'].join('.'),
						newRefreshPref = ['extensions', id, 'refreshPref'].join('.'),
						newReminderTypePref = ['extensions', id, 'reminderTypePref'].join('.');

					if (lowprefs.has(oldAutoRefreshPref) || 
						lowprefs.has(oldNotificationsPref)) {

						if (lowprefs.get(oldAutoRefreshPref) === true) {
							lowprefs.set(newRefreshPref, "automatic");  
						} else {
							lowprefs.set(newRefreshPref, "manual");             
						}
						if (lowprefs.get(oldNotificationsPref) === true) {
							lowprefs.set(newReminderTypePref, "modal");
						} else {
							lowprefs.set(newReminderTypePref, "toast");             
						}
						lowprefs.reset(oldNotificationsPref);
						lowprefs.reset(oldAutoRefreshPref);
					} 
					ss.MTTvsn = "CCC";
				}

				// "DDD" introduced js object based data storage 
				// starting with MTT 1.0.0, July 2013
				if (ss.MTTvsn === "CCC") {
					var i,
						j,
						dt = new Date(),
						scheme,
						dmn;

					if (dt.getHours() < 4) {
						dt = new Date(dt.getTime()-86400000);
					}

					// today
					ss.today.totalSecs = ss.mdata[0][0];
					ss.today.dayNum = ss.mdata[0][1];
					ss.today.headerText = ss.mdata[0][2];
					ss.today.monthNum = ss.mdata[0][4];
					ss.today.dateNum = ss.mdata[0][5];
					ss.today.dateObj = ss.mdata[0][6];
					ss.today.weekNum = ss.today.dayNum - ss.mdata[0][3];

					for (i=0; i<ss.dmns[0].length; i+=1) {
						scheme = urlMod.URL( ss.dmns[0][i][0] ).scheme;
						dmn = urlMod.URL( ss.dmns[0][i][0] ).host;
						ss.today.dmnsObj[ dmn ] = [ ss.dmns[0][i][1] , mtt_https_bool(scheme) ];
					}

					// previous days
					ss.ystrdayNum = ss.mdata[1][1];
					for (i=1; i<8; i+=1) {
						ss.days[ ss.mdata[i][1] ] = {
							dmnsArray : [],
							totalSecs : ss.mdata[i][0],
							headerText : ss.mdata[i][2],
							monthNum : ss.mdata[i][4],
							weekNum : ss.mdata[i][1] - ss.mdata[i][3]
						};

						for (j=0; j<ss.dmns[i].length; j+=1) {		
							scheme = urlMod.URL( ss.dmns[i][j][0] ).scheme;
							dmn = urlMod.URL( ss.dmns[i][j][0] ).host;
							ss.days[ ss.mdata[i][1] ].dmnsArray.push( [ dmn, ss.dmns[i][j][1], mtt_https_bool(scheme) ] );			
						}
					}

					// past 7 days summary
					ss.past7daySum = {
						dmnsArray: [],
						totalSecs : ss.mdata[8][0],
						headerText : ss.mdata[8][2],
						daysArray: []
					};

					for (i=0; i<ss.dmns[8].length; i+=1) {

						scheme = urlMod.URL( ss.dmns[8][i][0] ).scheme;
						dmn = urlMod.URL( ss.dmns[8][i][0] ).host;

						ss.past7daySum.dmnsArray.push( [ dmn, ss.dmns[8][i][1] , mtt_https_bool(scheme) ]);
					}

					// past 7 days - daily totals
					for (i=1; i<8; i+=1) {
						if (ss.mdata[i][0] !== 0 && ss.mdata[i][1] >= ss.mdata[0][1]-7) {
							ss.past7daySum.daysArray.push([
								ss.mdata[i][2], 
								ss.mdata[i][0],
								ss.mdata[i][1]
								]);
						}
					}
					ss.past7daySum.daysArray.sort( function(a,b) { return a[2] - b[2]; });

					// current week summary
					var k = 0,
						n,
						weekDmns = {},
						dayNum;

					for (dayNum in ss.days) {
						if (ss.days.hasOwnProperty(dayNum) && ss.days[dayNum].weekNum === ss.today.weekNum) {
							ss.weekSums[0].totalSecs += ss.days[dayNum].totalSecs;

							// mtt_data_merger( ss.days[dayNum].dmnsArray, weekDmns );
							// merge daily data
							for (n = 0; n < ss.days[dayNum].dmnsArray.length; n += 1 ) {
								if ( weekDmns.hasOwnProperty( ss.days[dayNum].dmnsArray[n][0] )) {
									// if domain is already logged, just add seconds
									weekDmns[ ss.days[dayNum].dmnsArray[n][0] ][0] += ss.days[dayNum].dmnsArray[n][1];
								} else {
									// else log domain
									// elements look like this: mozilla.org : [20, false], 
									weekDmns[ ss.days[dayNum].dmnsArray[n][0] ] = [
										ss.days[dayNum].dmnsArray[n][1], 
										ss.days[dayNum].dmnsArray[n][2] ];
								}
							}

							// daily totals for current week
							ss.weekSums[0].daysArray[k] = [ 
								ss.days[dayNum].headerText,
								ss.days[dayNum].totalSecs,
								dayNum
								];
							k += 1;
						}		
					}

					// convert temp obj data to array
					ss.weekSums[0].dmnsArray = mtt_to_array( weekDmns );

					// sort daysArray
					ss.weekSums[0].daysArray.sort( function(a,b) { return a[2] - b[2]; });

					// set header texts
					j = new Date((ss.today.weekNum + 1) * 86400000);
					k = new Date(j.getTime() + (6 * 86400000));
					ss.weekSums[0].headerText = "Week " + (j.getMonth()+1) + "/" + 
						j.getDate() + " - " + (k.getMonth()+1) + "/" + k.getDate();

					delete ss.mdata;
					delete ss.dmns;
					ss.MTTvsn = "DDD";
				}

				// "EEE" - whitelist entries no longer need "http://" or "https://"
				// starting with MTT 1.1.0, July 2013
				if (ss.MTTvsn === "DDD") {
					mtt_parse_whitelist_pref();
					ss.MTTvsn = "EEE";
				}

				// "10200" - starting with MTT 1.2.0, Oct 2013
				// A. ss.days is now an array, not an object, so it needs converting
                // B. new more efficient way to check for a new day, so updating users need to check 
				// the day one last time with the old method for a guaranteed smooth transition
				// 
				if (ss.MTTvsn === "EEE") {
                    
                    // convert ss.days from an object to an array
    				var tempArray = [],
						m;

					for (m in ss.days) {
						if (ss.days.hasOwnProperty(m)) {
							tempArray.push({
								dayNum : m,
								dmnsArray : ss.days[m].dmnsArray,
								totalSecs : ss.days[m].totalSecs,
								headerText : ss.days[m].headerText,
								monthNum : ss.days[m].monthNum,
								weekNum : ss.days[m].weekNum
							});
						}
					}
					ss.days = tempArray.slice();
					ss.days.sort( function(a,b) { return b.dayNum - a.dayNum; });
					ss.days.splice(70);
					if (ss.ystrdayNum) { ss.ystrdayNum = undefined; }
                    
                    // check for a new day one last time using the old method
					var EEEdt = new Date();
					if (ss.today.dateNum !== EEEdt.getDate()) {
						if  (EEEdt.getHours() > 3 || 
							// in case it's been more than a day and it's between midnight and 4am: 
							( Math.floor(EEEdt.getTime() / 86400000) ) - ss.today.dayNum > 1 ) {   
								mtt_new_day();
						}
					}
					mtt_set_nextDayStartsAt();

					ss.MTTvsn = 10200;
				}
			};
		mtt_upgrade_older_vsns();
		mtt_upgrade_older_vsns = null;
	} else {
		ss.MTTvsn = 10200;
	}
}

// on unload of add-on, remove listeners and close summary page if open
exports.onUnload = function(reason) {
	lowLevel.removeActivityListener( activityHandler );
    if (reason !== "upgrade") {
        var i, j;
        for (i = 0; i < windows.length; i += 1) {   
            for (j = 0; j < windows[i].tabs.length; j += 1) {
                if (windows[i].tabs[j].url === "resource://jid0-hynmqxa9zqgfjadreri4n2ahksi-at-jetpack/mind-the-time/data/index.html" ) {
                    windows[i].tabs[j].close();
                }
            }
        }
    } 
};

// no longer needed:
// on load of add-on start timing (which checks for a new day), 
// exports.main = function(options, callbacks) {
//		sdkTimers.setTimeout( mtt_pre_clock_on, 1000 ); }; 
