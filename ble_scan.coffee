class BleScan

  # Constants
  UPDATE_INTERVAL = 3000 # 3 seconds
  MAX_STACK_SIZE = 10
  PROXIMITY_THRESHOLD = -65.0
  SPIKE_THRESHOLD = 20

  constructor: () ->
    @stack = []
    @counter = 0
    @beaconProximity = 0
    @lastUpdate = Date.now()

  scan: (bleacon) =>
    if bleacon.minor == 1
      if @beaconProximity == 0
        @beaconProximity = bleacon.rssi
      else
        aggregate = 0.5*(bleacon.rssi + @beaconProximity)
        if Math.abs(aggregate - @beaconProximity) < SPIKE_THRESHOLD
          @beaconProximity = aggregate
    if @beaconProximity != 0 and @beaconProximity > PROXIMITY_THRESHOLD
      if (Date.now() - @lastUpdate) > UPDATE_INTERVAL
        @lastUpdate = Date.now()
        @counter += 1
    @stack.push(bleacon)
    if (@stack.length > MAX_STACK_SIZE)
      @stack.shift()

exports.BLE = BleScan
