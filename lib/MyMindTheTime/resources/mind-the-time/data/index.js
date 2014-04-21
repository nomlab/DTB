/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

// Javascript for the summary page (index.html)

"use strict";
var todayStamp,
    loadFail = document.getElementById("loadFailMessage");
// remove failed-to-load message
loadFail.parentNode.removeChild(loadFail); 


// load just data for today, previous day, current week, and previous week (for speed)
self.port.on("loadData-A2", function( ss_today, ss_ystrdy, ss_weekSums ) {
    var i,
        boxID,
    	hdr;
		
	document.getElementById("box0").innerHTML = "";
	mtt_make_table(ss_today.dmnsArray, ss_today.totalSecs, "Today, " + ss_today.headerText, "box0" );

	// if it's a new day, reload rest of data/tables
	if (ss_today.dayNum !== todayStamp) {
		todayStamp = ss_today.dayNum;
		
		// show previous day
		document.getElementById("box1").innerHTML = "";
		if (ss_ystrdy) {
			mtt_make_table(ss_ystrdy.dmnsArray, ss_ystrdy.totalSecs, 
				"Previous Day, " + ss_ystrdy.headerText, "box1");		
		} else {
			mtt_make_empty_table("Previous Day", "box1", "Soon this table will show a summary " + 
			"for the previous day. Additional tables covering the past 70 days will eventually appear below. " + 
			"(Logging for a new day begins at 4:00am, for all the late night surfers.)" );
		}
		
		// show current and previous week
		// clear non-day boxes
		for (i = 2; i < 21; i += 1) {
			document.getElementById("box" + i).innerHTML = "";
		}
		document.getElementById("day-rows").innerHTML = "";
		document.getElementById("rowMonths").style.display = "none";
		document.getElementById("rowWeeks").style.display = "none";
		document.getElementById("rowDays").style.display = "none";
		
		// do not move current week to previous week yet if new current week will be empty.
		// removes current week from the array if it is empty and previous week is not.
		if (ss_weekSums[0] && ss_weekSums[0].dmnsArray.length === 0 && 
			ss_weekSums[1] && ss_weekSums[1].dmnsArray.length > 0) {
				ss_weekSums.splice( 0, 1 );
		}
		
		// create current and previous week summaries
		for (i = 0; i < 2; i += 1) {
			boxID = "box" + (i + 2);

			if (ss_weekSums[i] && ss_weekSums[i].dmnsArray.length > 0) {
				
				hdr = ss_weekSums[i].headerText;
				if (i === 0) {
					hdr = "Current " + hdr;
				} else {
					hdr = "Previous " + hdr;
				}
				
				mtt_make_table(
					ss_weekSums[i].dmnsArray,
					ss_weekSums[i].totalSecs,
					hdr,
					boxID,
					ss_weekSums[i].daysArray );
			} else if (i === 0) {
				mtt_make_empty_table("Current Week", boxID, 
				"Soon this table will summarize the current week so far, with sub-totals for each day. " + 
				"(Data from today is not included in the current week until today is over.)");
			} else if (i === 1) {
				mtt_make_empty_table("Previous Week", boxID, 
				"Soon this table will summarize the previous week, with sub-totals for each day. " +
				"Tables covering the past ten weeks will eventually appear below.");
			}
		}		
		// load the rest
		self.port.emit('loadData-B1');
	}
});


// (re-)load more summaries (only called when page is first loaded or the day has changed)
self.port.on("loadData-B2", function( ss_past7daySum, ss_weekSums, ss_monthSums, ss_days_partA, more_days ) {
	var i, 
		boxID,
		hdr,
		dayButton,
		dayButtonText;


	// PAST 7 DAYS
	if (ss_past7daySum.dmnsArray.length > 0 ) {
		mtt_make_table(
			ss_past7daySum.dmnsArray,
			ss_past7daySum.totalSecs,
			ss_past7daySum.headerText, 
			"box4",
			ss_past7daySum.daysArray );
	} else {
		mtt_make_empty_table("Past 7 Days", "box4", "Soon this table will summarize " + 
		"the past seven days, including totals for the time spent browsing each day.");
	}
	
	
	// MONTHS
	document.getElementById("rowMonths").style.display = "block";
	
	// do not move the current month to previous if the new current month will be empty.
	// removes current month from the array if it is empty and previous month is not.
	if (ss_monthSums[0] && ss_monthSums[0].dmnsArray.length === 0 && 
		ss_monthSums[1] && ss_monthSums[1].dmnsArray.length > 0) {
			ss_monthSums.splice( 0, 1 );
	}
	
	for (i = 0; i < 6; i += 1) {
		boxID = "box" + (i + 5);
		
		if (ss_monthSums[i] && ss_monthSums[i].dmnsArray.length > 0) {	
			
			hdr = ss_monthSums[i].headerText;
			if (i === 0) { 
				hdr = "Current Month, " + hdr;
			} 
			else if (i === 1) { 
				hdr = "Previous Month, " + hdr;
			}
			
			mtt_make_table(
				ss_monthSums[i].dmnsArray,
				ss_monthSums[i].totalSecs,
				hdr,
				boxID );
		} else if (i === 0) {
			mtt_make_empty_table("Current Month", boxID, 
			"Soon this table will summarize the current month so far. " + 
			"(Data from today is not included in the current month until today is over.).");
		} else if (i === 1) {
			mtt_make_empty_table("Previous Month", boxID, 
			"Soon this table will summarize the previous month.  Eventually monthly summaries " + 
			"will be shown for the current month and the previous five months.");
			break;
		} 
	}	
	
	
	// WEEKS
	document.getElementById("rowWeeks").style.display = "block";
	
	// do not move current week to previous week if new current week will be empty
	// remove current week from the array if it is empty and previous week is not
	if (ss_weekSums[0] && ss_weekSums[0].dmnsArray.length === 0 && 
		ss_weekSums[1] && ss_weekSums[1].dmnsArray.length > 0) {
			ss_weekSums.splice( 0, 1 );
	}
	
	for (i = 0; i < 10; i += 1) {

		boxID = "box" + (i + 11); // box11 to box20
        
		if (ss_weekSums[i] && ss_weekSums[i].dmnsArray.length > 0) {
			
			hdr = ss_weekSums[i].headerText;
			if (i === 0) {
				hdr = "Current " + hdr;
			} else if (i === 1){
				hdr = "Previous " + hdr;
			}
			
			mtt_make_table(
				ss_weekSums[i].dmnsArray,
				ss_weekSums[i].totalSecs,
				hdr,
				boxID,
				ss_weekSums[i].daysArray );
            
		} else if (i === 0) {
			mtt_make_empty_table("More Weeks", boxID, 
			"Tables covering the past ten weeks will appear here.");
			document.getElementById("box12").style.display = "none";
		}
	}


	// DAYS
	document.getElementById("rowDays").style.display = "block";
	document.getElementById("day-rows").innerHTML = "";
	if (!ss_days_partA[0]) {
		mtt_make_day_rows( 1, 11, 21 );
		mtt_make_empty_table("More Days", "box21", 
			"Tables covering the past 70 days will appear here.");
	} else {
		mtt_make_day_tables( ss_days_partA, 11, 21 );

		if (more_days) {
			// show the "show days" button
			dayButton = document.createElement('p');
			dayButtonText = document.createTextNode( "Show All Day Summaries" );
			dayButton.appendChild( dayButtonText );
			dayButton.setAttribute('id', 'showDaysButton');
			document.getElementById("day-rows").appendChild( dayButton );
			document.getElementById("showDaysButton").addEventListener("click", function() {
				var node = document.getElementById("showDaysButton");
				node.parentNode.removeChild( node ); 
				self.port.emit('loadData-C1');
			}, false);
		}
	}
		
    // PREFERENCES
    document.getElementById("rowPrefs").style.display = "block";
});

// load data for all days (only called when button pushed to request it)
self.port.on("loadData-C2", function( ss_days_partB ) { 
	mtt_make_day_tables( ss_days_partB, 15, 29 ); 
});

var mtt_make_day_tables = function( ss_days, rowID, boxID ) {
	var i;
	mtt_make_day_rows( ss_days.length, rowID, boxID );

	for (i = 0; i < ss_days.length; i += 1) {
		if (ss_days[i] !== null && ss_days[i].totalSecs !== 0) {
			mtt_make_table( 
				ss_days[i].dmnsArray,
				ss_days[i].totalSecs, 
				ss_days[i].headerText, 
				"box" + boxID );
			boxID += 1;
		} 
	}
};

var mtt_make_day_rows = function( boxes, rowID, boxID ) {
	var i,
		node,
		rows = Math.ceil(boxes / 2);

	// make rows
	for (i = 0; i < rows; i += 1) {
		node = document.createElement('div');
		node.setAttribute('class','big-row');
		node.setAttribute('id', 'row' + (rowID + i));
		document.getElementById("day-rows").appendChild(node);
	}

	// make boxes
	for (i = 0; i < boxes; i += 1) {
		node = document.createElement('div');
		node.setAttribute('class','sum-box');
		node.setAttribute('id', 'box' + boxID);
		document.getElementById("row" + rowID).appendChild(node);
		boxID += 1;
		
		// use even and odd toggle to increment to next rowID
		if (i % 2 !== 0) { rowID += 1; }
	}
};


// initiate loading of data
self.port.emit('loadData-A1');

// listen for data refresh call
self.port.on("loadData-A0", function() { self.port.emit('loadData-A1'); });

// takes https boolean (or string) and converts it to string
// true = https, false = http, string = string
var mtt_https_string = function( scheme ) {
	if (scheme === false) { return "http"; } 
	else if (scheme === true) { return "https"; }
	else { return scheme; }
};


// generate summary tables
var mtt_make_table = function(dmns, tsecs, header, boxId, daysArray) {
	var len = dmns.length,
		c,
		k,
		row = [],
		cell = [],
		cont = [],
		linktext,
		rowsShown = 10,
		dateheader = document.createElement('h4'),
		datetext = document.createTextNode( header ),
		tab = document.createElement('table'),
		tbo = document.createElement('tbody'),
		show;
		
	tab.setAttribute('class','MTTtable');
	tab.appendChild(tbo);
	document.getElementById(boxId).appendChild(tab);
	
	// A. create date header row
	dateheader.setAttribute('class', 'dateheader');
	dateheader.appendChild(datetext); 
	
	row[0] = document.createElement('tr');
	row[0].setAttribute('class', 'headerrow');
	
	cell[0] = document.createElement('td');
	cell[0].setAttribute('class', 'headertd');
	cell[0].colSpan = "5";
	cell[0].appendChild(dateheader);

	row[0].appendChild(cell[0]);
	tbo.appendChild(row[0]);

	// B. create daysArray rows
	if (daysArray) {
		for(c = 0; c < daysArray.length; c += 1){
			row[c] = document.createElement('tr');
			row[c].setAttribute('id', 'daysArray-trow' + boxId + c);
		
			// day name (saturday)
			cont[1] = document.createTextNode( daysArray[c][0] );
			
			// time
			cont[2] = document.createTextNode(mtt_format_time(daysArray[c][1]) );

			// percent
			if (tsecs === 0) { 
				cont[3] = document.createTextNode("0%");
			} else {
				cont[3] = document.createTextNode(Math.round((daysArray[c][1] / tsecs) * 100) + "%"); 
			}
		
			// graph
			cont[4] = mtt_make_graph( daysArray[c][1] );

			// put it all together
			for(k = 0; k < 5; k += 1) {
				cell[k] = document.createElement('td');
				if (k === 1) { 
					cell[k].setAttribute('class', 'domain-td'); 
				}
				if (cont[k]) {
					cell[k].appendChild(cont[k]);
				}
				row[c].appendChild(cell[k]);
			}
			tbo.appendChild(row[c]);
		}	
	}
	
	// C. create total header row
	row[0] = document.createElement('tr');
	row[0].setAttribute('class','totalrow');

	cont[0] = document.createTextNode(" "); 
	cont[1] = document.createTextNode("Total"); 
	cont[2] = document.createTextNode(mtt_format_time(tsecs) ); 
	cont[3] = document.createTextNode( "100%" ); 
	cont[4] = mtt_make_graph(tsecs); 

	for (k = 0; k < 5; k += 1) {
		cell[k] = document.createElement('td');
		cell[k].appendChild(cont[k]);
		row[0].appendChild(cell[k]);	
	}
	tbo.appendChild(row[0]);
	
	// D. create domain rows
	for (c = 0; c < len; c += 1) {
		
		row[c] = document.createElement('tr');
			row[c].setAttribute('id', 'trow' + boxId + c);
			if (c > rowsShown-1) {
				row[c].setAttribute('style', 'display:none');
			}
		
		// row number
		cont[0] = document.createTextNode(c+1 + "."); 

		// domain
		if (dmns[c][0] === "O3Xr2485dmmDi78177V7c33wtu7315.net") {
			cont[1] = document.createTextNode("No websites logged (only time)");
		} else {
			cont[1] = document.createElement('a'); 
			cont[1].setAttribute('href', mtt_https_string( dmns[c][2] ) + "://" + dmns[c][0]);
			cont[1].setAttribute('class', 'domainlink');
			cont[1].setAttribute('target', '_blank');

			// getDom = dmns[c][0] // .replace(/(.*?\/\/).*?/, "");

			// linktext = document.createTextNode(getDom);
			linktext = document.createTextNode( dmns[c][0] );
			cont[1].appendChild(linktext);		
		}
		
		// time
		cont[2] = document.createTextNode(mtt_format_time(dmns[c][1]) ); 

		// percent
		if (tsecs === 0) { 
			cont[3] = document.createTextNode("0%");
		} else {
			cont[3] = document.createTextNode(Math.round((dmns[c][1] / tsecs) * 100) + "%"); 
		}

		// graph
		cont[4] = mtt_make_graph( dmns[c][1] );

		// put it all together
		for(k = 0; k < 5; k += 1) {
			cell[k] = document.createElement('td');
			if (k === 1) {
				cell[k].setAttribute('class', 'domain-td');
			}
			cell[k].appendChild(cont[k]);
			row[c].appendChild(cell[k]);	
		}
		tbo.appendChild(row[c]);
	}

	// E. create show more row
	if (len > rowsShown) {
		show = document.createElement('a');
		show.setAttribute('class', 'showmore');
	
		var showtext = document.createTextNode( "Show " + (len - rowsShown) + " More" );
		show.appendChild(showtext);
		show.addEventListener("click", function() { 
			mtt_show_more_row(boxId, len, rowsShown, true);
			}, false);
	
		row[0] = document.createElement('tr');
		row[0].setAttribute('id', 'showrow'+ boxId );

		cell[0] = document.createElement('td');
		cont[0] = document.createTextNode(" "); 
		cell[0].appendChild(cont[0]);
		row[0].appendChild(cell[0]);

		cell[1] = document.createElement('td');
		cell[1].setAttribute('id', 'showCell' + boxId);
		cell[1].colSpan = "4";
		cell[1].appendChild(show);
	
		row[0].appendChild(cell[1]);
		tbo.appendChild(row[0]);  
	}	
};

// handle "show/hide more rows" 
var mtt_show_more_row = function(boxId, len, rowsShown, showMore) {
	var i,
		showLink = document.createElement('a'),
		showCell = document.getElementById('showCell' + boxId),
		showWhatText,
		displayValue;
	
	if (showMore === true) {
		showWhatText = document.createTextNode( "Show Only First 10" );
		displayValue = null;
		showLink.addEventListener("click", function() { 
			mtt_show_more_row(boxId, len, rowsShown, false); 
			// scroll to top of table (using boxId)
			document.defaultView.postMessage( boxId, "*");
			}, false);
	}
	else {
		showWhatText = document.createTextNode( "Show " + (len - rowsShown) + " More" );
		displayValue = "none";
		showLink.addEventListener("click", function() { 
			mtt_show_more_row(boxId, len, rowsShown, true); 
			}, false);
	}
	
	showLink.setAttribute('class', 'showmore');
	showLink.appendChild(showWhatText);

	showCell.innerHTML = "";
	showCell.appendChild(showLink);

	for (i = rowsShown; i < len; i+=1) {
		document.getElementById("trow" + boxId + i).style.display = displayValue;
	}
};

// generate bar graphs
var mtt_make_graph = function(secs) {
	var minsPerPx = 2,
		totalMins = Math.floor(secs / 60),
		hours = Math.floor(totalMins / 60),
		mins = Math.floor(totalMins % 60),
		lig,
		g,
		graphUL=document.createElement('ul'); 
		
	graphUL.setAttribute('class', 'graphUL');
	// sets how many hours per row:
	// graphUL.style.maxWidth = ((hours < 5) ? (totalMins / minsPerPx) : ( 300 / minsPerPx)  ) + 12 + "px";
	for (g = 0; g < hours; g += 1) {
		lig = document.createElement('li');
		lig.setAttribute('class', 'graphLI');
		// lig.style.width=((60 / minsPerPx) - 1) + "px";
		graphUL.appendChild(lig);
	}
	lig = document.createElement('li');
	lig.setAttribute('class', 'graphLI');
	lig.style.width = (mins / minsPerPx) + "px";
	graphUL.appendChild(lig);
	return graphUL;
};

// generate empty starter tables
var mtt_make_empty_table = function(header, boxId, contentText) {   
	
	// create table
	var row = [],
		cell = [],
		cont = [],
		tab = document.createElement('table'),
		tbo = document.createElement('tbody'),
		dateheader = document.createElement('h4'),
		datetext = document.createTextNode( header );
		
	tab.setAttribute('class','MTTtable');
	tab.appendChild(tbo);

	document.getElementById(boxId).appendChild(tab);
	
	// create date header row
	dateheader.setAttribute('class', 'dateheader');
	dateheader.appendChild(datetext); 
	
	row[0] = document.createElement('tr');
	row[0].setAttribute('class', 'headerrow');
	
	cell[0] = document.createElement('td');
	cell[0].setAttribute('class', 'headertd');
	cell[0].colSpan = "5";
	cell[0].appendChild(dateheader);
	
	row[0].appendChild(cell[0]);
	tbo.appendChild(row[0]);

	// create message row
	row[1] = document.createElement('tr');
	cont[0] = document.createTextNode(contentText);

	cell[1] = document.createElement('td');
	cell[1].colSpan = "5";
	cell[1].setAttribute('class', 'emptytableTD');
	cell[1].appendChild(cont[0]);

	row[1].appendChild(cell[1]);
	tbo.appendChild(row[1]);	
};


// formatting time display
var mtt_format_time = function(time) {
	time = Math.abs(time);
	var h = Math.floor(time / 3600),
		m = Math.floor(time / 60) % 60;	 
	return ((h < 1) ? "0:" : h + ":") + 
		((m < 10) ? ((m < 1) ? "00" : "0" + m) : m);
};

// get refresh pref
self.port.emit("getPref", "refreshPref");

self.port.on("getPref", function(prefName, value) {
	if (prefName === "refreshPref") {  
		if (value === "manual") {
			document.getElementById("reloadLi").style.display="inline-block";
		}
		else if (value === "automatic") {
			document.getElementById("reloadLi").style.display="none";
		}
	} 
});

// addons manager button handler
document.getElementById("addonsManagerButton").addEventListener("click", function(){
	self.port.emit("goToPrefs");	
}, false);

// reload button handler
document.getElementById("reloadButton").addEventListener("click", function(){
	try {
		self.port.emit("loadData-A1"); 
		// flicker the current day so user knows it was updated
		document.getElementById("box0").style.visibility = "hidden";
		setTimeout( function() { document.getElementById("box0").style.visibility = "visible"; }, 80);	
	}
	catch(e){
		window.location.reload();
	}
}, false);

/*
// for testing
document.getElementById("newDayButton").addEventListener("click", function(){
	self.port.emit("newDay"); 
}, false);
*/