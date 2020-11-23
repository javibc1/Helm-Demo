const http = require('http');
const port = 8080;

let server = http.createServer(function(req,res){
  res.writeHead(200, {
    'content-type':'text/html'
  });
  
  res.write('<h1 style="color: blue;">Hello World V3</h1>');
  res.end();
});

server.listen(port);