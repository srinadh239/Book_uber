Based on Arrival time get duration
calculate departure time
start checking from 60 min before departure time based on optimization logic
get estimated pickup time from Uber api
get duration_in_traffic from estimated_pickup_time+time_now
buffer = arrival_time-duration_in_traffic-estimated_pickup_time-time_now
if buffer <= estimated_pickup_time
	book uber
else
	check after next check_time

check_time = (buffer*10)/travel_time

Optimization
traveltime 1 hr
buffer 1 hr
10 min

traveltime 1hr15min
buffer 35min
5min

travel time 1hr
buffer 45min
7min

travel 1hr30min
buffer35min
4min

(buffer/traveltime)*20

traveltime 1 hr
buffer 1 hr
20 min

traveltime 1hr15min
buffer 35min
10min

travel time 1hr
buffer 45min
14min

travel 1hr30min
buffer35min
8min

Accuracy and optimization are inversely proportional

if we increase the number multiplied to buffer Accuracy decreases and optimization increases