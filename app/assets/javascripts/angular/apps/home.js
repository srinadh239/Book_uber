var timeToTravel = angular.module("timeToTravel", ['ngRoute']);

timeToTravel.directive('clockPicker', function(){
    return {
        link: function(scope, element, attrs, ngModel){
            $(element).clockpicker().on('change', function(ev){
                scope.$apply(function(){
                	console.log(angular.element(element[0].querySelectorAll('[ng-model]')[0]).controller('ngModel'));
                    angular.element(element[0].querySelectorAll('[ng-model]')[0]).controller('ngModel').$setViewValue(element[0].children[0].value);
                }); 
            });
        }
      }   })

timeToTravel.run(["$rootScope","$location", function($rootScope, $location){
    console.log("asdg");
}]);