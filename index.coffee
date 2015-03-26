http = require('http')
express = require('express')
path = require('path')
Bleacon = require('bleacon')

stack = []
counter = 0
beacon_1_proximity = 0
proximity_threshold = -65.0
spike_threshold = 20
MAX_STACK_SIZE = 10

app = express()
app.set 'port', process.env.PORT || 3000
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'

assets = require("connect-assets")
paths = [
  "assets/js",
  "assets/css"
#  "node_modules/jquery/dist",
#  "node_modules/semantic-ui/dist"
  ]

app.use assets({paths: paths})
# app.use express.static(process.cwd() + '/public')

app.get '/', (req, res) ->
  res.render('index')

app.get '/stack', (req, res) ->
  res.write(JSON.stringify(stack));
  res.end()

app.get '/counter', (req, res) ->
  res.write(JSON.stringify(counter));
  res.end()

http.createServer(app).listen app.get('port'), () ->
  console.log('Express server listening on port ' + app.get('port'))

Bleacon.on 'discover', (bleacon) ->
  console.log JSON.stringify(bleacon)
  if bleacon.minor == 1
    if beacon_1_proximity == 0
      beacon_1_proximity = bleacon.rssi
    else
      aggregate = 0.5*(bleacon.rssi + beacon_1_proximity)
      if Math.abs(aggregate - beacon_1_proximity) < spike_threshold
        beacon_1_proximity = aggregate
  if beacon_1_proximity > proximity_threshold
    counter += 1
  stack.push(bleacon)
  if (stack.length > MAX_STACK_SIZE)
    stack.shift()

Bleacon.startScanning()
