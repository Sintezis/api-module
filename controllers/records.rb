# TODO: add request flags
# - envelope(boolean) -> if true wraps data in 'data' envelope
# - page, per_page(varchar) -> paging for large data sets

class RecordsController < Sinatra::Base
	enable :method_override
	helpers Sinatra::ApiRequestHelper 

	before do
		content_type :json
		#error 400 unless valid_request?
	end

	#Fetching
	get '/:model' do 
		halt(api_error 1001) unless valid_model?	
		records ||= model.all() || halt(api_error 1001)
		api_response records, model
	end
	
	get '/:model/:id' do 
		halt(api_error 1001) unless valid_model?	
		record ||= model.get(record_id) || halt(api_error 1002)
		api_response record, model
	end
	
	get '/:model/:id/:child_model' do		
		halt(api_error 1001) unless valid_model? && valid_child_model?	
		parent_record ||= model.get(record_id) || halt(api_error 1002)
		records ||= parent_record.send child_model_method || halt(api_error 1002)
		api_response records, child_model
	end
	
	get '/:model/:id/:child_model/:child_id' do 
		halt(api_error 1001) unless valid_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1002)
		record ||= parent_record.send(child_model_method).get(child_id) || halt(api_error 1002)
		api_response record, child_model
	end

	get '/:model/:id/:join_model/:join_id/:child_model' do
		halt(api_error 1001) unless valid_model? && valid_join_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1002)
		record ||= parent_record.send(join_model_method).get(join_id).send(child_model_method) || halt(api_error 1002)
		api_response record, child_model
	end

	get '/:model/:id/:join_model/:join_id/:child_model/:child_id' do
		halt(api_error 1001) unless valid_model? && valid_join_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1002)
		record ||= parent_record.send(join_model_method).get(join_id).send(child_model_method).get(child_id) || halt(api_error 1002)
		api_response record, child_model
	end

	#Creating 
	post '/:model' do
		halt(api_error 1001) unless valid_model?
		new_record = model.new
		new_record.attributes = api_request[:json_body]
		halt(api_error 1003, new_record) unless new_record.save
		api_response new_record, model
	end
	
	post '/:model/:id/:child_model' do
		halt(api_error 1001) unless valid_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1002)
		new_record = parent_record.send(child_model_method).new
		new_record.attributes = api_request[:json_body]
		halt(api_error 1003, parent_record) unless parent_record.save
		api_response new_record, model
	end

	post '/:model/:id/:join_model/:child_model' do
		halt(api_error 1001) unless valid_model? && valid_join_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1002)
		join_record = parent_record.send(join_model_method).new 
		new_record = child_model.new
		new_record.attributes = api_request[:json_body]
		new_record.send(join_model_method) << join_record
		halt(api_error 1003, parent_record) unless parent_record.save
		api_response new_record, child_model
	end

	#Updating 
	put '/:model/:id' do
		halt(api_error 1008) unless valid_model?
		record ||= model.get(record_id) || halt(api_error 1001)
		record.attributes = api_request[:json_body]
		halt(api_error 1003, record) || record.save
		api_response record, model
	end
	
	put '/:model/:id/:child_model/:child_id' do 
		halt(api_error 1008) unless valid_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1001)
		record ||= parent_record.send(child_model_name).get(child_id) || halt(api_error 1001)
		record.attributes = api_request[:json_body]
		halt(api_error 1003, record) unless record.save
		api_response record, child_model
	end

	put '/:model/:id/:join_model/:join_id/:child_model/:child_model_id' do
		halt(api_error 1008) unless valid_model? && valid_join_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1001)
		join_record ||= parent_record.send(join_model_method).get(join_id) || halt(api_error 1001)
		record ||= join_record.send(child_model_method).get(child_model_id) || halt(api_error 1001)
		record.attributes = api_request[:json_body]
		halt(api_error 1003, record) unless record.save
		api_response record, child_model
	end

	#Deleting
	delete '/:model/:id' do
		halt(api_error 1008) unless valid_model?
		record ||= model.get(record_id) || halt(api_error 1001)
		halt(api_error 1004) unless record.destroy
		{:deleted => true}.to_json
	end
	
	delete '/:model/:id/:child_model/:child_id' do
		halt(api_error 1008) unless valid_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1001)
		record ||= parent_record.send(child_model_name).get(child_id)
		halt(api_error 1004) unless record.destroy
		{:deleted => true}.to_json
	end

	delete '/:model/:id/:join_model/:join_id/:child_model/:child_mode_id' do
		halt(api_error 1008) unless valid_model? && valid_join_model? && valid_child_model?
		parent_record ||= model.get(record_id) || halt(api_error 1001)
		join_record ||= parent_record.send(join_model_method).get(join_id) || halt(api_error 1001)
		record ||= join_record.send(child_model_method).get(child_model_id) || halt(api_error 1001)
		halt(api_error 1004) unless record.destroy
		{:deleted => true}.to_json
	end

end