http = require('http')
express = require('express')
path = require('path')
Bleacon = require('bleacon')

Bles = require("./ble_scan").BLE
Ble = new Bles()

app = express()
app.set 'port', process.env.PORT || 3000
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'

minutes = 1
the_interval = minutes * 10 * 1000

assets = require("connect-assets")
paths = [
  "assets/js",
  "assets/css"
  ]

app.use assets({paths: paths})
# app.use express.static(process.cwd() + '/public')

app.get '/', (req, res) ->
  res.render('index')

app.get '/stack', (req, res) ->
  res.write(JSON.stringify(BLE.stack));
  res.end()

app.get '/counter', (req, res) ->
  res.write(JSON.stringify(BLE.counter));
  res.end()

http.createServer(app).listen app.get('port'), () ->
  console.log('Express server listening on port ' + app.get('port'))

Bleacon.on 'discover', (bleacon) ->
  console.log JSON.stringify(bleacon)
  Ble.scan bleacon

setInterval () ->
  console.log("I am doing my 1 minute check");
  Ble.report()
  console.log Ble.beacons
, the_interval

Bleacon.startScanning()
