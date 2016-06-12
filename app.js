var http = require('http');
var amqp = require('amqp');

if (process.env.VCAP_SERVICES) {
  var env = JSON.parse(process.env.VCAP_SERVICES);
  var credentials = env['user-provided'][0]['credentials'];
} else {
  var credentials = {"url": "amqp://user1:secret@localhost:5672/vhost"}
}

var port = (process.env.VCAP_APP_PORT || 1337);
var host = (process.env.VCAP_APP_HOST || '0.0.0.0');

http.createServer(function(req, res) {
  
  res.writeHead(200, {'Content-Type': 'text/plain'});

  var conn = amqp.createConnection({url: credentials.url});

  conn.on('ready', function() {
    var exchange = conn.exchange('test-event', {type: 'fanout'});
    conn.queue('test-event-queue', function(q) {
      q.bind(exchange, '');
      q.subscribe(function(json) {
        res.end("Fetched message: " + json.body);
        conn.end();
      });
    
      exchange.publish('test-event-queue', {'body': 'Hello, world!'} );
    });
  });  

}).listen(port, host);

