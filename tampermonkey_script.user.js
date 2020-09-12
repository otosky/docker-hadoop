// ==UserScript==
// @name         Docker-Hadoop Localhost
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  try to take over the world!
// @author       You
// @match        http://localhost:8188/*
// @match        http://localhost:8088/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Your code here...
    var links = document.getElementsByTagName("a");
    for (var i=0,imax=links.length; i<imax; i++){
        links[i].href = links[i].href.replace(/historyserver/, 'localhost');
        links[i].href = links[i].href.replace(/resourcemanager/, 'localhost');
}
})();
