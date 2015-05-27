Bleacon = require('bleacon')
Estimote = Bleacon.Estimote
async = require('async')
Beacon = require('./beacon').Beacon
Report = require('./report').Report

class BleScan
  constructor: () ->
    @beacons = {}
    @reporter = new Report()

  hashKey: (bleacon) =>
    bleacon.uuid + bleacon.major + bleacon.minor

  scan: (bleacon) =>
    key = @hashKey(bleacon)
    @beacons[key] = new Beacon(bleacon) unless @beacons[key]
    @beacons[key].readProximity(bleacon)
    @beacons[key].updateCounter()

#    beacon.updateBatteryLevel()

  report: () =>
    console.log "reporting..."
    @reporter.post(@beacons)
    @beacons = {}

exports.BLE = BleScan
