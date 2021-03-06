fs = require('fs')
request = require('request')

class Report
  HOST = ""
  ID = ""

  constructor: () ->
    @config()

  post: (beacons, callback) ->
    if @beaconData(beacons).length > 0
      console.log @beaconData(beacons)
      request.post(
        HOST,
        { json: @transform(beacons) },
        (error, response, body) ->
          if !error && response.statusCode == 200
            console.log "post complete."
          else
            callback(error, body)
      )

  beaconData: (beacons) ->
    result = []
    for id, beacon of beacons
      if beacon.counter > 0
        data =
          uuid: beacon.id(),
          exits: beacon.counter,
          battery: beacon.batteryLevel
        result.push data
    result

  transform: (beacons) ->
    { mac: ID,
    timestamp: (new Date()),
    beacons: @beaconData(beacons) }

  config: () ->
    fs.readFile './config.json', 'utf-8', (err, data) ->
      if err
        console.log "FATAL An error occurred trying to read in the file: " + err
        process.exit -2
      if data
        config = JSON.parse data
        HOST = config.host
        ID = config.id
      else
        console.log "Config failed."
        process.exit -1

exports.Report = Report
