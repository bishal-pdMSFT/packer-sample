import http = require('http');
import os = require('os');
var port = process.env.port || 1337
http.createServer(function (req, res) {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Hello World from old instance' + os.hostname());
}).listen(port);