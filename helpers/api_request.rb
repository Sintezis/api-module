require 'sinatra/base'

module Sinatra
	module ApiRequestHelper

		def api_request
			body = nil
			unless request.request_method == 'GET' || 'DELETE'
				request.body.rewind
				body = JSON.parse(request.body.read)
			end
			{:request => request, :params => params, :json_body => body}
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

		def child_model_name
			api_request[:params][:child_model]
		end

		def valid_child_model?
			Object.const_defined? child_model_name.capitalize[0...-1]
		end

		def child_model
			Object.const_get(child_model_name)
		end


		def valid_request?
			request.media_type == 'application/json'
		end

		def api_error code
			errors = [
				{
					:code => 1001,
					:msg => "Invalid data request, or data missing."
				},
				{
					:code => 1002,
					:msg => "Record not created, invalid data request, or sent data invalid."
				},
				{
					:code => 1003,
					:msg => "Record not saved, invalid data request, or sent data invalid."
				},
				{
					:code => 1004,
					:msg => "Record not deleted, data missing, or invalid data request."
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
			error_msg.to_json
		end
	
	end
	
	helpers ApiRequestHelper

end