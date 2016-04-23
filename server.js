var express = require('express');
var app = express();

app.get('/', function(req, res) {
  res.send('hello world');
});

app.get('/v1/api/term/:id/longest-preview-media-url', function (req, res) {
    //var taskId = req.params.id;
    
    res.send('params were ' + JSON.stringify(req.params.id) + '\n')

});

app.listen(8080);
