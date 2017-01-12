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
		record ||= model.get(record_id) || halt(api_error 1001)
		record
	end
	
	get '/:model/:id/:child_model' do 
		halt(api_error 1008) unless valid_model? && valid_child_model?	
		parent_record ||= model.get(record_id) || halt(api_error 1001)
		records ||= parent_record.send child_model_name || halt(api_error 1001)
		records.to_json
	end
	
	get '/:model/:id/:child_model/:child_id' do 
		halt(api_error 1008) unless valid_model? && valid_child_model?
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
		new_record.to_json
	end
	
	post '/:parent_model/:id/:child_model' do
		halt(api_error 1008) unless valid_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1001)
		new_record = parent_record.send(child_model_name).new
		new_record.attributes = api_request[:json_body]
		halt(api_error 1002) unless new_record.save
		new_record.to_json
	end

	# #Updating 
	put '/:model/:id' do
		halt(api_error 1008) unless valid_model?
		record ||= model.get(record_id) || halt(api_error 1001)
		record.attributes = api_request[:json_body]
		halt(api_error 1003) || record.save
		record.to_json
	end
	
	put '/:parent_model/:id/:child_model/:child_id' do 
		halt(api_error 1008) unless valid_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1001)
		record ||= parent_record.send(child_model_name).get(child_record_id) || halt(api_error 1001)
		record.attributes = api_request[:json_body]
		halt(api_error 1003) unless record.save
		record.to_json
	end

	# #Deleting
	delete '/:model/:id' do
		halt(api_error 1008) unless valid_model?
		record ||= model.get(record_id) || halt(api_error 1001)
		halt(api_error 1004) unless record.destroy
		{:deleted => true}.to_json
	end
	
	delete '/:parent_model/:id/:child_model/:child_id' do
		halt(api_error 1008) unless valid_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1001)
		record ||= parent_record.send(child_model_name).get(child_record_id)
		halt(api_error 1004) unless record.destroy
		{:deleted => true}.to_json
	end

end