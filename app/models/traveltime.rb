class Traveltime < ActiveRecord::Base
  
  def checkapi(id)
  	Delayed::Worker.logger.debug("Log Entry")
  	Delayed::Worker.logger.debug(id)
  	traveltime = Traveltime.find(id)
  	arrival_time = DateTime.now.change({ hour: traveltime.time.split(':')[0].to_i, min: traveltime.time.split(':')[1].to_i, sec: 0 }).strftime('%s')
  	uber_response = HTTP.get('https://api.uber.com/v1/estimates/time', :params => {:start_latitude=>traveltime.source_latitude, :start_longitude=>traveltime.source_longitude, :server_token=>"BPehDhjfmMaomcn2ZbnWuyaqRzrZoTS1ezAMlZs1"})
  	Request.create({"apirequests" => "[ #{Time.now} ] - Requested Uber Api for [ #{traveltime.email}]"})
  	uberGOFound = false
  	uber_response_json = JSON.parse(uber_response)
  	Delayed::Worker.logger.debug(uber_response_json)
  	estimate_time = ""
  	uber_response_json["times"].each do |res|
  		if res["localized_display_name"] == "uberGO"
  			uberGOFound = true
  			estimate_time = res["estimate"]
  		end
  	end		
  	if !uberGOFound
  		Delayed::Worker.logger.debug("Ubergo not found")
  		traveltime.delay(run_at: 1.minutes.from_now).checkapi(id)
  		p "Uber not found pushed to queue"
  	else
  		Delayed::Worker.logger.debug(estimate_time)
		time_now = Time.now.strftime('%s').to_i + estimate_time
  		google_response = HTTP.get('https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins='+traveltime.source_latitude.to_s+','+traveltime.source_longitude.to_s+'&destinations='+traveltime.destination_latitude.to_s+','+traveltime.destination_longitude.to_s+'&departure_time='+time_now.to_s+'&key=AIzaSyB6ky0s6kmaxH15hsxsNHKuZeI6n_OG2eA')
  		Request.create({"apirequests" => "[ #{Time.now} ] - Requested Maps Api for [ #{traveltime.email}]"})
  		google_response_json = JSON.parse(google_response)
  		Delayed::Worker.logger.debug(google_response_json)
  		check_time = time_now+google_response_json["rows"][0]["elements"][0]["duration_in_traffic"]["value"]
  		travel_time = google_response_json["rows"][0]["elements"][0]["duration_in_traffic"]["value"]+estimate_time
  		Delayed::Worker.logger.debug(arrival_time)
  		Delayed::Worker.logger.debug(Time.now.strftime('%s'))
  		Delayed::Worker.logger.debug(travel_time)
  		if travel_time+Time.now.strftime('%s').to_i<arrival_time.to_i
	  		buffer =  arrival_time.to_i - travel_time -Time.now.strftime('%s').to_i
	  		Delayed::Worker.logger.debug(buffer)
	  		check_from_now = (buffer*10)/travel_time
	  		check_from_now_min = check_from_now/60
	  		Delayed::Worker.logger.debug(check_from_now_min)
	  		if buffer <= estimate_time
	  			Delayed::Worker.logger.debug("Time to book uber")
	  			# send mail
	  			UserMailer.book_uber(traveltime.email).deliver_now unless traveltime.email.nil?
	  		elsif check_from_now == 0 || (buffer <= 600 && estimated_time <= buffer)
	  			Delayed::Worker.logger.debug("add to queue and check each minute")
	  			traveltime.delay(run_at: 1.minutes.from_now).checkapi(id)
	  		else
	  			Delayed::Worker.logger.debug("added to queue")
	  			# add to queue
	  			Delayed::Worker.logger.debug(check_from_now)
	  			traveltime.delay(run_at: check_from_now.minutes.from_now).checkapi(id)
	  			Delayed::Worker.logger.debug("After added to queue")
	  		end
	  	else
	  		Delayed::Worker.logger.debug("cannot book uber")
	  		UserMailer.cannot_book_uber(traveltime.email).deliver_now unless traveltime.email.nil?
	  	end
  	end
  end
end
