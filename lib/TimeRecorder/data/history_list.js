// JavaScript for History List page.
function displayHistory(history, index, array) {
    // get tbody
    var tableRef = document.getElementById("histories");

    // insert empty row to first line
    var newRow   = tableRef.insertRow(0);

    // add cells to new line
    // When execute insertCell, cell is inserted to row hed.
    // So, we have to execute insertCell 表とは逆順に
    var thumbnail      = newRow.insertCell(0);
    var path           = newRow.insertCell(0);
    var title          = newRow.insertCell(0);
    var referenceTime  = newRow.insertCell(0);

    // add value to each cell
    var thumbnailElement = document.createElement('img');
    thumbnailElement.src = history.thumbnail;
    thumbnailElement.alt = history.title;
    thumbnail.appendChild(thumbnailElement);

    var pathElement = document.createElement('a');
    pathElement.href = history.path;
    pathElement.innerHTML = history.path;
    path.appendChild(pathElement);

    var titleText = document.createTextNode(history.title);
    title.appendChild(titleText);

    var localeStartTime = new Date(history.start_time).toLocaleString();
    var localeEndTime = new Date(history.end_time).toLocaleString();
    var referenceTimeText = document.createTextNode(localeStartTime + " - " + localeEndTime);
    referenceTime.appendChild(referenceTimeText);
}

self.port.on("getHistories", function(histories) {
    if (histories) { histories.forEach(displayHistory); }
});
