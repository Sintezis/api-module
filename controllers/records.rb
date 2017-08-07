# TODO: add request flags
# - envelope(boolean) -> if true wraps data in 'data' envelope
# - page, per_page(varchar) -> paging for large data sets

class RecordsController < Sinatra::Base
	enable :method_override
	helpers Sinatra::ApiHelpers

	before do
		content_type :json
		error 400 unless @request.media_type == 'application/json'
	end

	#Fetching
	get '/:table' do 
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid?
		records ||= @api_manager.table.model.all() || api_error(1002)
		@api_manager.respond :with => records
	end
	
	get '/:table/:id' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid?
		record ||= @api_manager.table.model.get(@api_manager.table.id) || api_error(1002)
		@api_manager.respond :with => record
	end
	
	get '/:table/:id/:child_table' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid? && @api_manager.child_table.valid?
		parent_record ||= @api_manager.table.model.get(@api_manager.table.id) || api_error(1002)
		records ||= parent_record.send(@api_manager.child_table.name) || api_error(1002)
		@api_manager.respond :with => records
	end
	
	get '/:table/:id/:child_table/:child_id' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid? && @api_manager.child_table.valid?
		parent_record ||= @api_manager.table.model.get(@api_manager.table.id) || api_error(1002)
		record ||= parent_record.send(child_model_method).get(child_id) || halt(api_error 1002)
		@api_manager.respond :with => record
	end

	get '/:table/:id/:join_table/:join_id/:child_table' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid? && @api_manager.child_table.valid? && @api_manager.join_table.valid?
		parent_record ||= @api_manager.table.model.get(record_id) || api_error(1002)
		records ||= parent_record.send(@api_manager.join_table.name).get(@api_manager.join_table.id).send(@api_manager.child_table.name) || api_error(1002)
		@api_manager.respond :with => records
	end

	get '/:table/:id/:join_table/:join_id/:child_table/:child_id' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid? && @api_manager.child_table.valid? && @api_manager.join_table.valid?
		parent_record ||= @api_manager.table.model.get(record_id) || api_error(1002)
		record ||= parent_record.send(@api_manager.join_table.name).get(@api_manager.join_table.id).send(@api_manager.child_table.name).get(@api_manager.child_table.id) || api_error(1002)
		@api_manager.respond :with => record
	end

	#Creating 
	post '/:table' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless api_manager.table.valid?
		new_record = @api_manager.table.model.new
		new_record.attributes = @api_manager.json_body
		api_error(1003, new_record.errors) unless new_record.save
		@api_manager.respond :with => new_record
	end
	
	post '/:table/:id/:child_table' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid? && @api_manager.child_table.valid?
		parent_record ||= @api_manager.table.model.get(@api_manager.table.id) || api_error(1002)
		new_record = parent_record.send(@api_manager.child_table.name).new
		new_record.attributes = @api_manager.json_body
		api_error(1003, parent_record.errors) unless parent_record.save
		@api_manager.respond :with => new_record
	end

	post '/:table/:id/:join_table/:child_table' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid? && @api_manager.child_table.valid? && @api_manager.join_table.valid?
		parent_record ||= @api_manager.table.model.get(@api_manager.table.id) || api_error(1002)
		join_record = parent_record.send(@api_manager.join_table.name).new 
		new_record = @api_manager.child_table.model.new
		new_record.attributes = @api_manager.json_body
		new_record.send(@api_manager.join_table.name) << join_record
		api_error(1003, parent_record.errors) unless parent_record.save
		@api_manager.respond :with => new_record
	end

	#Updating 
	put '/:table/:id' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid?
		record ||= @api_manager.table.model.get(@api_manager.table.id) || api_error(1002)
		record.attributes = @api_manager.json_body
		api_error(1003, record.errors) || record.save
		@api_manager.respond :with => record
	end
	
	put '/:table/:id/:child_table/:child_id' do 
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid? && @api_manager.child_table.valid?
		parent_record ||= @api_manager.table.model.get(@api_manager.table.id) || api_error(1001)
		record ||= parent_record.send(@api_manager.child_table.name).get(@api_manager.child_table.id) || api_error(1001)
		record.attributes = @api_manager.json_body
		api_error(1003, record.errors) unless record.save
		@api_manager.respond :with => record
	end

	put '/:table/:id/:join_table/:join_id/:child_table/:child_id' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid? && @api_manager.child_table.valid? && @api_manager.join_table.valid?
		parent_record ||= @api_manager.table.model.get(@api_manager.table.id) || api_error(1002)
		join_record ||= parent_record.send(@api_manager.join_table.name).get(@api_manager.join_table.id) || api_error(1002)
		record ||= join_record.send(@api_manager.child_table.name).get(@api_manager.child_table.id) || api_error(1002)
		record.attributes = @api_manager.json_body
		api_error(1003, record.errors) unless record.save
		@api_manager.respond :with => record
	end

	#Deleting
	delete '/:table/:id' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid?
		record ||= @api_manager.table.model.get(@api_manager.table.id) || api_error(1002)
		api_error(1004) unless record.destroy
		{:deleted => true}.to_json
	end
	
	delete '/:table/:id/:child_table/:child_id' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid? && @api_manager.child_table.valid?
		parent_record ||= @api_manager.table.model.get(@api_manager.table.id) || api_error(1002)
		record ||= parent_record.send(@api_manager.child_table.name).get(@api_manager.child_table.id)
		api_error(1004) unless record.destroy
		{:deleted => true}.to_json
	end

	delete '/:table/:id/:join_table/:join_id/:child_table/:child_id' do
		@api_manager = APIManager.new request, params
		api_error(1001) unless @api_manager.table.valid? && @api_manager.child_table.valid? && @api_manager.join_table.valid?
		parent_record ||= @api_manager.table.model.get(@api_manager.table.id) || api_error(1002)
		join_record ||= parent_record.send(@api_manager.join_table.name).get(@api_manager.join_table.id) || api_error(1002)
		record ||= join_record.send(@api_manager.child_table.name).get(@api_manager.child_table.id) || api_error(1002)
		api_error(1004) unless record.destroy
		{:deleted => true}.to_json
	end

end