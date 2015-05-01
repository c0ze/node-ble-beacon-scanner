http = require('http')
express = require('express')
path = require('path')
Bleacon = require('bleacon').Bleacon
Estimote = require('bleacon').Estimote

async = require('async')

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

Estimote.discover( (estimote) ->
  async.series([
    (callback) ->
      estimote.on('disconnect', () ->
        console.log('disconnected!')
        Bleacon.startScanning()
        return
      )
      estimote.connect(callback)
    ,
    (callback) ->
      estimote.discoverServicesAndCharacteristics(callback)
    ,
    (callback) ->
      estimote.readMajor (major) ->
        console.log "Major : " + major
        callback()
    ,
    (callback) ->
      estimote.readBatteryLevel (batteryLevel) ->
        console.log "Battery Level : " + batteryLevel
        callback()
    ,
    (callback) ->
      estimote.readPowerLevel (powerLevel, dBm) ->
        console.log "Power Level : " + powerLevel
        console.log "dBm : " + dBm
        callback()
    ,
    (callback) ->
      estimote.disconnect(callback)
    ])
)

Bleacon.on 'discover', (bleacon) ->
  console.log JSON.stringify(bleacon)
  BLE.scan bleacon

Bleacon.startScanning()
