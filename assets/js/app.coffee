    angular.module('test', []).controller('TestController', ($scope, $http, $timeout) ->
      tick = ->
        $http.get('/stack').then( (data) ->
          $scope.beacon_stack = data.data.filter (beacon) ->
            beacon.minor == 1
          for beacon in $scope.beacon_stack
            if beacon.rssi < -65
              beacon.table_class = "error"
            else
              beacon.table_class = "positive"
#            if beacon.proximity == "near"
#              beacon.table_class = "error"
#            else if beacon.proximity == "immediate"
#              beacon.table_class = "positive"
          $timeout tick, 1000
        )
      tick()
    )
