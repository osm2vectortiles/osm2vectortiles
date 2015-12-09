var http = require('http');
var httpProxy = require('http-proxy');
var fs = require('fs');
var path = require('path');

httpProxy.createProxyServer({target:'http://tileserver:80'}).listen(3001);
http.createServer(function (req, res) {
  res.writeHead(200, { 'Content-Type': 'text/html' });

  var filename = path.join(process.cwd(), 'index.html');
  var fileStream = fs.createReadStream(filename);
  fileStream.pipe(res);
}).listen(3000);
