require 'sinatra/base'

module Sinatra
	module ApiHelpers
		
		class APIManager
			attr_accessor :table, :child_table, :join_table

			def initialize request, params
				@request = request
				@params = params
				@table = TableManager.new @params[:table], @params[:id] unless @params[:table].nil?
				@child_table = TableManager.new @params[:child_table], @params[:child_id] unless @params[:child_table].nil?
				@join_table = TableManager.new @params[:join_table], @params[:join_id] unless @params[:join_table].nil?
			end

			def json_body
				body = nil
				if @request.content_lenght > 0
					@request.body.rewind
					body = ::JSON.parse(@request.body.read)
				end
				body
			end

			def respond data
				data = data[:with]
				expand = @params[:expand] == "1"		
				model_methods = @child_table.nil? ? @table.relationships : @child_table.relationships
				response = expand ? data.to_json(:methods => model_methods) : data.to_json
				response
			end

		end
		
		class TableManager
			attr_accessor :name, :model_name, :id

			def initialize requested_table, record_id
				@name = requested_table
				@model_name = @name.capitalize if Object.const_defined? @name.capitalize
				@model_name = @name.capitalize[0...-1] if Object.const_defined? @name.capitalize[0...-1] 
				@id ||= record_id
			end

			def valid?
				Object.const_defined? @model_name
			end

			def model
				Object.const_get @model_name
			end

			def all_records
				model.all()
			end

			def get_record
				model.get(@id)
			end


			def relationships
				methods = []
				model.relationships.each do |relationship|
					method = relationship.name.to_sym
					methods << method
				end	
				methods
			end
		end

		def api_error code, model_errors = nil, halt_request = true
			errors = [
				{
					:code => 1001,
					:msg => "Invalid model request. Requested table can not be found."
				},
				{
					:code => 1002,
					:msg => "Invalid data request. Requested record can not be found."
				},
				{
					:code => 1003,
					:msg => "Record not saved. Missing required field, or invalid data sent."
				},
				{
					:code => 1004,
					:msg => "Record not deleted. Error while deleting record."
				}
			]

			error_msg = errors.find {|error| error[:code] == code}

			unless model_errors.nil?
				error_msg[:desc] = []
				model_errors.each do |error|
					error_msg[:desc] << error
				end
			end

			if halt_request
				halt error_msg.to_json
			else
				error_msg.to_json
			end

		end
	
	end
	
	helpers ApiHelpers

end