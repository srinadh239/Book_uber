timeToTravel.controller("TimeController", ['$scope', '$http', '$window', function($scope, $http, $window){
	console.log("hello");
	var current_date = new Date();
	var current_time = current_date.getTime()/1000;
	$scope.time = ""
	$scope.error = false
	var arrival_time_split;
	var arrival_time_seconds;
	var time_to_depart;
	var departure_time;
	$scope.afterSubmit= function(){
		if($scope.source && $scope.destination && $scope.time && $scope.email){
			$scope.error = false
			var d = new Date();
			arrival_time_split = $scope.time.split(":");
			d.setHours(arrival_time_split[0], arrival_time_split[1])
			arrival_time_seconds = d.getTime()/1000;
			console.log(arrival_time_seconds);
			console.log($scope.time);
			if(current_time>arrival_time_seconds){
				alert("Please enter correct time");
			}
			else{
				$http.get("/booking_time?source_latitude="+$scope.source.split(",")[0]+"&source_longitude="+$scope.source.split(",")[1]+"&destination_latitude="+$scope.destination.split(",")[0]+"&destination_longitude="+$scope.destination.split(",")[1]+"&departure_time="+$scope.time+"&email="+$scope.email)
				.then(function(response){
					console.log(response.dats);
					if(response.data.msg)
						alert(response.data.msg);
				},function(response){
					alert("Something went wrong, please try again later");
				});
			}
		}
		else{
			$scope.error = true
		}
	}
	$scope.api_data = []
	$scope.getApiList = function(){
		$http.get("/hit_api_list")
		.then(function(response){
			console.log(response);
			$scope.api_data = response.data
		},function(response){
			alert("Something went wrong, please try again later");
		})
	}
}])