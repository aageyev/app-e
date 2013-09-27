var express = require('express');
var cluster = require('cluster');
var fs = require('fs');

if (cluster.isMaster) {
  var cpuCount = require('os').cpus().length;
  for (var i = 0; i < cpuCount; i += 1) {
    cluster.fork();
  }
  cluster.on('exit', function(worker) { 
    console.log('worker die');
    console.log(worker.process);
  });
  console.log('Running the cluster...');    
} else {
  var express = require('express');
  var app = express();
  app.get('/', function (req, res) {
    // res.send('Hello World!');
    res.send('Hello from Worker ' + cluster.worker.id);
  });
  console.log('tmp/app-e.' + cluster.worker.id + '.sock');
  
  var socket = 'tmp/app-e.' + cluster.worker.id + '.sock';
  if(fs.existsSync(socket)){
    fs.unlinkSync(socket);
  }

  app.listen(socket,function () {
    fs.chmodSync(socket, 0777);
    console.log('Server started: '+socket);
  });

  // console.log('Worker ' + cluster.worker.id + ' running!');
}
