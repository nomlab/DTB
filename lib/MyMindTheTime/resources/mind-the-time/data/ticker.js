/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */
 
function init() {
    var tickerDiv = document.getElementById("tickerDiv"),
        modeDot = document.getElementById("modeDot");
    addon.port.on("updateTicker", function(tickerText) {tickerDiv.textContent = tickerText;});  
    addon.port.on("tickerOn", function() {tickerDiv.style.color="#555";});
    addon.port.on("tickerOff", function() {tickerDiv.style.color="#aaa";});
    addon.port.on("updateMode", function(mode) {
        if (mode === 1) {modeDot.style.borderColor="transparent";}
        else if (mode === 2) {modeDot.style.borderColor="#00ab00";}
        else if (mode === 3) {modeDot.style.borderColor="#777";}
        else if (mode === 4) {modeDot.style.borderColor="#5555dd";}
    });
    addon.port.emit("getTimerMode");
}