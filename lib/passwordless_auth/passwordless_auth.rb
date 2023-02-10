module PasswordlessAuth
  require "PasswordlessAuth/configuration"
  require 'PasswordlessAuth/gem/version'
  class << self
    attr_accessor :configuration
    require 'net/http'
    require 'uri'
    require 'json'

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def send_otp(username)
      request_body = { username: username }
      initiate_request('/send_otp', request_body)
    end

    def verify_otp(username, otp)
      request_body = { username: username, otp: otp }
      initiate_request('/verify_otp', request_body)
    end

    def verify_session(auth_token)
      request_body = { auth_token: auth_token }
      initiate_request('/verify_session', request_body)
    end

    def application_details(application_name)
      request_body = { application_name: application_name }
      initiate_request('/application_details', request_body, 'get')
    end

    def initiate_request(path, request_body, method = 'post')
      #passwordless_auth base url
      base_url = 'https://passwordless-authetication.herokuapp.com/api'
      uri = URI.parse(base_url + path)

      #add headers
      headers = { 'Content-Type': 'application/json', 'Api-Key': api_key }
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      # Initialise Http method
      request = method == 'get'? Net::HTTP::Get.new(uri.request_uri, headers) : Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = request_body.to_json

      # Send the request
      response = http.request(request)

      #return the response
      JSON.parse(response.body).with_indifferent_access
    end

    def api_key
      configuration.api_key
    end
  end
end