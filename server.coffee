_ = require('lodash')
express = require('express')
app = express()
request = require('request-promise') # request, properly promisified via bluebird
parse = require('xml2js').parseString;

# at the top are URLs and XML / logical parser operations
vocabURL = 'http://www.gaia.com/api/vocabulary/1/'
vocabParse = (xml) ->
  xml.response.terms[0].term[0]['$'].tid
videosURL = 'http://www.gaia.com/api/videos/term/'
videoParse = (xml) ->
  array = _.map xml.response.titles[0].title, (element) ->
    if element && element.preview
      {
        titleNID: element['$'].nid
        preview: element.preview[0]['$']
      }
  _.first(_.sortBy array, (element) ->
    if element && element.preview
      -1*element.preview.duration
  )

mediaURL = 'http://www.gaia.com/api/media/'
mediaParse = (xml) ->
  xml.response.mediaUrls[0]['$'].bcHLS

# generic parse or return nicely formatted error here
safeParse = (parseFn,xml) ->
  #console.log('parsing xml now: ' + JSON.stringify(xml))
  try
    parseFn xml
  catch err
    {
      error: 500
      massage: ' endpoint unexpected xml response ' + JSON.stringify(err)
    }

# promisified request wrapper, returns result of parsing a result from a URL
requestWrapper = (url, parseFn) ->
  #console.log('saw url ' + url)
  request(
    uri: url
    resolveWithFullResponse: true
  ).then((response) ->
    #console.log("saw response " + JSON.stringify(response))
    if response.statusCode == 200
      parsed = ''
      parse(response.body, { trim: true }, (err, result) ->
        if err
          {
            error: 500
            message: ' endpoint xml response couldn\'t be parsed ' + JSON.stringify(err)
          }
        else
          parsed = parseFn result
        return
      )
      parsed
    else
      {
        error: response.statusCode
        message: ' endpoint unavailable'
      }
  ).catch (err) ->
    {
      error: 500
      message: ' unexpected request failure '  + JSON.stringify(err)
    }

# router handler that watches at our pre-specified path on port 4000
app.get '/v1/api/term/:id/longest-preview-media-url', (req, res) ->
  #console.log 'server saw input ID param : ' + req.params.id + '\n'
  if isNaN(req.params.id) # basic fuzz defense
    res.sendstatus(400).send error: 'Please supply a numeric id parameter.'
  else
    resultFull = {}
    requestWrapper(vocabURL+req.params.id,vocabParse)
    .then((result) ->
      requestWrapper(videosURL+result,videoParse)
    ).then((result1) ->
      resultFull = result1
      requestWrapper(mediaURL+result1.preview.nid,mediaParse)
    ).then((result2) ->
      res.send
        bcHLS: result2
        titleNid: resultFull.titleNID
        previewNid: resultFull.preview.nid
        previewDuration: resultFull.preview.duration
    ).catch((err) ->
      res.send 'unexpected err : ' + JSON.stringify(err)
    )

app.listen 4000