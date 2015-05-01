Bleacon = require('bleacon').Bleacon
Estimote = require('bleacon').Estimote

class BleScan

  # Constants
  UPDATE_INTERVAL = 3000 # 3 seconds
  MAX_STACK_SIZE = 10
  PROXIMITY_THRESHOLD = -65.0
  SPIKE_THRESHOLD = 20

  constructor: () ->
    @beacons = {}

  hashKey: (bleacon) =>
    bleacon.uuid + bleacon.major + bleacon.minor

  initialize: (bleacon) =>
    @beacons[@hashKey(bleacon)] = {}
    @beacons[@hashKey(bleacon)].stack = []
    @beacons[@hashKey(bleacon)].counter = 0
    @beacons[@hashKey(bleacon)].beaconProximity = 0
    @beacons[@hashKey(bleacon)].batteryLevel = 0
    @beacons[@hashKey(bleacon)].batteryLevelUpdate = Date.now()
    @beacons[@hashKey(bleacon)].lastUpdate = Date.now()

  scan: (bleacon) =>
    console.log @beacons
    @initialize(bleacon) unless @beacons[@hashKey(bleacon)]
    beaconHash = @beacons[@hashKey(bleacon)]
    if beaconHash.beaconProximity == 0
      beaconHash.beaconProximity = bleacon.rssi
    else
      aggregate = 0.5*(bleacon.rssi + beaconHash.beaconProximity)
      if Math.abs(aggregate - beaconHash.beaconProximity) < SPIKE_THRESHOLD
        beaconHash.beaconProximity = aggregate
    if beaconHash.beaconProximity != 0 and beaconHash.beaconProximity > PROXIMITY_THRESHOLD
      if (Date.now() - beaconHash.lastUpdate) > UPDATE_INTERVAL
        beaconHash.lastUpdate = Date.now()
        beaconHash.counter += 1
    beaconHash.stack.push(bleacon)
    if (beaconHash.stack.length > MAX_STACK_SIZE)
      beaconHash.stack.shift()

exports.BLE = BleScan
