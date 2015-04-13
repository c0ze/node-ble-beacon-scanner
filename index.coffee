http = require('http')
express = require('express')
path = require('path')
Bleacon = require('bleacon')

BleScan = require("./ble_scan").BLE
BLE = new BleScan()

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
  res.write(JSON.stringify(BLE.stack));
  res.end()

app.get '/counter', (req, res) ->
  res.write(JSON.stringify(BLE.counter));
  res.end()

http.createServer(app).listen app.get('port'), () ->
  console.log('Express server listening on port ' + app.get('port'))

Bleacon.on 'discover', (bleacon) ->
  console.log JSON.stringify(bleacon)
  BLE.scan bleacon

Bleacon.startScanning()
