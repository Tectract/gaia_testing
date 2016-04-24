var express = require('express');
var app = express();
var Promise = require("bluebird");
var request = Promise.promisify(require("request"));

app.get('/v1/api/term/:id/longest-preview-media-url', function (req, res) {

  // res.send('params were ' + JSON.stringify(req.params.id) + '\n')
  if (isNaN(req.params.id)) {
    res.status(400).send({error: 'Please supply a numeric id parameter.'});
  } else {
    request('http://www.gaia.com/api/vocabulary/1/' + req.params.id, function (error, response, body) {
      if (!error && response.statusCode == 200) {
        console.log(body) // Show the HTML for the Google homepage.
        res.send(body)
      } else {
        res.status(500).send({error: 'Vocabularies api endpoint unavailable.'});
      }
    }).then(function () {
      console.log("next")
    })
  }
});

app.listen(8080);
