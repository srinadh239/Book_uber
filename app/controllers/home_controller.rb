require 'http'
class HomeController < ApplicationController
  def index
  end

  def time_to_email
  	details = {}
  	details["source_latitude"] = params[:source_latitude]
  	details["source_longitude"] = params[:source_longitude]
  	details["destination_latitude"] = params[:destination_latitude]
  	details["destination_longitude"] = params[:destination_longitude]
  	details["time"] = params[:departure_time]
  	details["email"] = params[:email]
  	object = Traveltime.create(details)
  	time_in_seconds = DateTime.now.change({ hour: object.time.split(':')[0].to_i, min: object.time.split(':')[1].to_i, sec: 0 })
  	p time_in_seconds
  	response = HTTP.get('https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins='+object.source_latitude.to_s+','+object.source_longitude.to_s+'&destinations='+object.destination_latitude.to_s+','+object.destination_longitude.to_s+'&arrival_time='+time_in_seconds.to_s+'&key=AIzaSyB6ky0s6kmaxH15hsxsNHKuZeI6n_OG2eA')
  	api_request = Request.create({"apirequests" => "[ #{Time.now} ] - Requested Maps Api for [ #{object.email}]"})
  	response_json = JSON.parse(response)
  	time_now = Time.now.strftime('%s').to_i
  	time_to_travel = response_json["rows"][0]["elements"][0]["duration"]["value"]
  	start_time = time_in_seconds.to_i - time_to_travel
  	if start_time<time_now
  		p "you cannot book uber now"
  		res = {}
  		res["msg"] = "you cannot book uber now"
  		render json: res, status: :ok
  		return
  	elsif (start_time-3600)<time_now
  		p "start checking from now"
  		object.checkapi(object.id)
  	elsif (start_time-3600)>time_now
  		p "added to queue minutes from now to start checking"
  		delay_time = (start_time-3600-time_now)/60
  		p delay_time
  		object.delay(run_at: delay_time.minutes.from_now).checkapi(object.id)
  	end
  	render nothing: true, status: :ok
  end

  def api_list
  	render :json => Request.all.collect{|request| request}, status: :ok
  end
end
