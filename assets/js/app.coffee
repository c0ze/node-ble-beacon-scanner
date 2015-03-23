    angular.module('test', []).controller('TestController', ($scope, $http, $timeout) ->
      tick = ->
        $http.get('/stack').then( (data) ->
#          $scope.beacon_stack = data.data
          $scope.beacon_stack = data.data.filter (beacon) ->
            beacon.minor == 1
          for beacon in $scope.beacon_stack
            if beacon.proximity == "near"
              beacon.table_class = "inside"
            else
              beacon.table_class = "outside"
          $timeout tick, 1000
        )
        $http.get('/counter').then( (data) ->
	  $scope.counter = data.data
	)
      tick()
    )
