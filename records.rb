# TODO: add request flags
# - envelope(boolean) -> if true wraps data in 'data' envelope
# - page, per_page(varchar) -> paging for large data sets
# - expand(boolean) -> expand to json child relations
# - embed(boolean) -> embed record in parent record

class RecordsController < Sinatra::Base
	enable :method_override
	helpers Sinatra::ApiRequestHelper 

	before do
		content_type :json
		#error 400 unless valid_request?
	end

	#Fetching
	get '/:model' do 
		halt(api_error 1008) unless valid_model?	
		records ||= model.all() || halt(api_error 1001)
		records.to_json(:methods=> [:accounts])
	end
	
	get '/:model/:id' do 
		halt(api_error 1008) unless valid_model?	
		record_id = api_request[:params][:id]
		record ||= model.get(record_id) || halt(api_error 1001)
		record
	end
	
	get '/:model/:id/:child_model' do 
		halt(api_error 1008) unless valid_model? && valid_child_model?
		record_id = api_request[:params][:id]			
		parent_record ||= model.get(record_id) || halt(api_error 1001)
		records ||= parent_record.send child_model_name || halt(api_error 1001)
		records.to_json
	end
	
	get '/:model/:id/:child_model/:child_id' do 
		halt(api_error 1008) unless valid_model? && valid_child_model?
		record_id = api_request[:params][:id]
		child_record_id = api_request[:params][:child_id]
		parent_record ||= model.get(record_id) || halt(api_error 1001)
		record ||= parent_record.send(child_model_name).get(child_record_id) || halt(api_error 1001)
		record.to_json
	end

	#Creating 
	post '/:model' do
		halt(api_error 1008) unless valid_model?
		new_record = model.new
		new_record.attributes = api_request[:json_body]
		halt(api_error 1002) unless new_record.save
		new_record
	end
	
	post '/:parent_model/:id/:child_model' do
		halt(api_error 1008) unless valid_model? && valid_child_model?

	end

	# #Updating 
	# put '/:model/:id' {}
	# put '/:parent_model/:id/:child_model/:id' {}

	# #Partial Update
	# patch '/:model/:id' {}
	# patch '/:parent_model/:id/:child_model/:id' {}

	# #Deleting
	# delete '/:model/:id' {}
	# delete '/:parent_model/:id/:child_model/:id' {}

	# #DB Sync
	# post '/sync/:model' {}




	# ## 	EVENTOMATE SPECIFIC REQUESTS, FIXING API DESIGN

	# # GET RECORD BY RELATIONS
	# get '/user/:id/event' do
	# 	user_id = api_request[:params][:id]
	# 	user = User.get(user_id)
	# 	Response.for :get_record, api_request do |response|
	# 		hosting_events = user.events.all
	# 		response.data = hosting_events
	# 		response.submit 
	# 	end
	# end

	# get '/event/:id/attendee' do
	# 	event_id = api_request[:params][:id]
	# 	event = Event.get(event_id)
	# 	attending = []
	# 	Response.for :get_record, api_request do |response|
	# 		event.attendees.each do |attendee|
	# 			attending << User.get(attendee.user_id).account
	# 		end
	# 		response.data = attending
	# 		response.submit
	# 	end
	# end

	# # CREATE EVENT
	# put '/user/:id/event' do 
	# 	# parent_model_id = params[:id]
	# 	user_id = api_request[:params][:id]
	# 	user = User.get(user_id)
	# 	Response.for :create_record, api_request do |response|
	# 		# parent_model = Object.const_get(model_name).get(id)
	# 		event = user.events.new
	# 		event.attributes = api_request[:json_body]
	# 		event.save
	# 		#attendee = event.attendees.create(:user_id => user_id)
			
	# 		if user.save	
	# 			response.data = event
	# 		else
	# 			event.errors.each do |e| 
	# 				puts e
	# 			end
				
	# 			# error = Error.code 1002
	# 			# error.original_error = event.errors
	# 			# response.error =  error

	# 			response.error = Error.code 1002 #record not created, invalid data request, or sent data invalid
	# 		end
	# 		response.submit
	# 	end
	# end

	# # RSVP EVENT
	# # Needs to create new record in attendees table, containing user_id of the rsvping user
	# put '/event/:id/attendee' do
	# 	event_id = api_request[:params][:id]
	# 	event = Event.get(event_id)
	# 	Response.for :create_record, api_request do |response|
	# 		attendee = event.attendees.create(:user_id => api_request[:json_body]["user_id"])
	# 		if event.save
	# 			response.data = attendee
	# 		else
	# 			response.error = Error.code 1002 #record not created, invalid data request, or sent data invalid 
	# 		end
	# 		response.submit
	# 	end
	# end

	# # SAVE EVENT (?)

	# #CREATE RECORD
	# # put '/:parent_model/:id/:child_model/' do 
	# put '/:model' do
	# 	Response.for :create_record, api_request do |response|
	# 		if valid_model?
	# 			new_record = Object.const_get(model_name).new 	
	# 	 		new_record.attributes = api_request[:json_body]
	# 			if new_record.save 
	# 				response.data = new_record
	# 			else
	# 				response.error = Error.code 1002 #record not created, invalid data request, or sent data invalid 
	# 			end
	# 		else
	# 			response.error = Error.code 1008 #invalid model request
	# 		end
	# 		response.submit
	# 	end
	# end

	# #SAVE RECORD
	# post '/:model/?:id?' do
	# 	Response.for :save_record, api_request do |response|
	# 		id = api_request.params[:id]
	# 		if valid_model?
	# 			if id.nil?
	# 				record = Object.const_get(model_name).new
	# 			else
	# 				record = Object.const_get(model_name).get(id)
	# 			end
	# 			unless record.nil?
	# 				record.attributes = api_request.for :update_record
	# 				if record.save
	# 					response.data = record
	# 				else
	# 					response.error = Error.code 1003 #record not saved, invalid data request, or sent data invalid
	# 				end
	# 			else
	# 				response.error = Error.code 1001 #invalid data request, or data missing
	# 			end
	# 		else
	# 			response.error = Error.code 1008 #invalid model request
	# 		end
	# 		response.submit
	# 	end
	# end
	
	# #DELETE
	# delete '/:model/:id' do
	# 	Response.for :delete_record, api_request do |response|
	# 		id = api_request.params[:id]
	# 		if valid_model?
	# 			record = Object.const_get(model_name).get(id)
	# 			unless record.nil?
	# 				if record.destroy
	# 					response.data = {:deleted => true}
	# 				else	
	# 					response.error = Error.code 1004 #record not deletes, data missing, or invalid data request
	# 				end
	# 			else
	# 				response.error = Error.code 1001 #invalid data request, or data missing
	# 			end
	# 		else
	# 			response.error = Error.code 1008 #invalid model request
	# 		end
	# 		response.submit
	# 	end
	# end

	# # SYNC RECORDS REQUEST
	# post '/sync/:model' do
	# 	Response.for :sync_records, api_request do |response|
	# 		if valid_model?

	# 		else
	# 			response.error = Error.code 1008 #invalid model request
	# 		end
	# 		response.submit
	# 	end
	# end 

end

