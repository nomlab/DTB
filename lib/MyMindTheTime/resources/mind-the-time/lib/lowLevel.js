/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

// lowLevel.js - Mind the Time's module
// for accessing low-level APIs 

"use strict";

var { Ci } = require("chrome"),
    systemEvents = require("sdk/system/events");

exports.addActivityListener = function(callback) {
	systemEvents.on("user-interaction-active", callback);
};

exports.removeActivityListener = function(callback) {
	systemEvents.off("user-interaction-active", callback);
};