"use strict";
var http = require('http');
var os = require('os');
var port = process.env.port || 1337;
http.createServer(function (req, res) {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Hello World from ' + os.hostname());
}).listen(port);
//# sourceMappingURL=server.js.map