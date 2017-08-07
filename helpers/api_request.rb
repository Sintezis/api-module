require 'sinatra/base'

module Sinatra
	module ApiRequestHelper

		def api_request
			body = nil
			method = request.request_method
			unless method == 'GET' || method == 'DELETE'
				request.body.rewind
				body = ::JSON.parse(request.body.read)
			end
			{:request => request, :params => params, :json_body => body}
		end

		def api_response data, model
			envelope = api_request[:params][:envelope] == "1"  
			expand = api_request[:params][:expand] == "1"
			model_methods = relations :for => model
			response = data.to_json
			response = data.to_json(:methods => model_methods) if expand
			# response = {:data => data}.to_json if envelope
			# response = {:data => data}.to_json(:methods => model_methods) if envelope && expand
			response
		end

		def relations data
			model = data[:for]
			methods = []
			model.relationships.each do |relationship|
				method = relationship.name.to_sym
				methods << method
			end	
			methods
		end

		def valid_media_type?
			request.media_type == 'application/json'
		end
				
		def record_id
			api_request[:params][:id]
		end

		def model_name
			api_request[:params][:model].capitalize[0...-1]
		end

		def valid_model?
			Object.const_defined? model_name
		end

		def model
			Object.const_get(model_name)
		end

		def child_id
			api_request[:params][:child_id]
		end

		def child_model_property_name
			child_model_method[0...-1]
		end

		def child_model_method
			api_request[:params][:child_model]
		end

		def child_model_name
			api_request[:params][:child_model].capitalize[0...-1]
		end

		def valid_child_model?
			Object.const_defined? child_model_name
		end

		def child_model
			Object.const_get child_model_name
		end

		def join_id 
			api_request[:params][:join_id]
		end

		def join_model_method
			api_request[:params][:join_model]
		end

		def join_belongs_to
			child_model_property_name
		end

		def join_model_name 
			api_request[:params][:join_model].capitalize[0...-1]
		end

		def join_model
			Object.const_get join_model_name
		end

		def valid_join_model?
			Object.const_defined? join_model_name 
		end

		def api_error code, model = nil
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
					:msg => "Record not deleted. Requested record can not be found."
				},
				{
					:code => 1005,
					:msg => "Provided email is in use by another user."
				},
				{
					:code => 1006,
					:msg => "Invalid email and password combination."
				},
				{
					:code => 1007,
					:msg => "There is no user with provided email in our records."
				},
				{
					:code => 1008,
					:msg => "Invalid model request."
				},
				{
					:code => 1009,
					:msg => "Invalid recovery code."
				}
			]

			error_msg = errors.find {|error| error[:code] == code}

			unless model.nil?
				error_msg[:desc] = []
				model.errors.each do |error|
					error_msg[:desc] << error
				end
			end

			error_msg.to_json
		end
	
	end
	
	helpers ApiRequestHelper

end