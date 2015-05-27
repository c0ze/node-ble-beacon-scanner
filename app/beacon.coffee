class Beacon
  SPIKE_THRESHOLD = 20
  UPDATE_INTERVAL = 3000 # 3 seconds
  BATTERY_UPDATE_INTERVAL = 10000 # 10 seconds
  PROXIMITY_THRESHOLD = -65.0
  MAX_STACK_SIZE = 1

  constructor: (bleacon) ->
    @stack = []
    @counter = 0
    @beaconProximity = 0
    @batteryLevel = 0
    @batteryLevelUpdate = Date.now()
    @lastUpdate = Date.now()
    @major = bleacon.major
    @minor = bleacon.minor
    @uuid = bleacon.uuid

  readProximity: (bleacon) ->
    if @beaconProximity == 0
      @beaconProximity = bleacon.rssi
    else
      aggregate = 0.5*(bleacon.rssi + @beaconProximity)
      if Math.abs(aggregate - @beaconProximity) < SPIKE_THRESHOLD
        @beaconProximity = aggregate
    # I'm not sure what I am doing with the stack atm
    # this may be removed
    @stack.push(bleacon)
    if (@stack.length > MAX_STACK_SIZE)
      @stack.shift()

  updateCounter: () ->
    if @beaconProximity != 0 and @beaconProximity > PROXIMITY_THRESHOLD
      if (Date.now() - @lastUpdate) > UPDATE_INTERVAL
        @lastUpdate = Date.now()
        @counter += 1

  updateBatteryLevel: () ->
    if @batteryLevel == 0 or (Date.now() - @batteryLevelUpdate) > BATTERY_UPDATE_INTERVAL
      @readBattery()

  batteryCallback: () ->
    console.log "Battery callback"

  readBattery: () ->
    console.log "reading battery"
    console.log @major
    readValues = {}
    returnValues = {}
    returnValues.batteryLevel = 0
    beaconMajor = @major
    Estimote.discover( (estimote) ->
      async.series([
        (callback) ->
          estimote.on('disconnect', () ->
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
            readValues.major = major
            console.log "Major : " + major
            callback()
        ,
        (@batteryCallback) ->
          estimote.readBatteryLevel (batteryLevel) ->
            console.log readValues
            console.log beaconMajor
            if readValues.major == beaconMajor
              console.log "Updating Battery Level : " + batteryLevel
              @batteryLevel = batteryLevel
              @batteryLevelUpdate = Date.now()
              return returnValues
            batteryCallback()
        ,
        (callback) ->
          estimote.disconnect(callback)
          return returnValues
        ])
      )

exports.Beacon = Beacon
