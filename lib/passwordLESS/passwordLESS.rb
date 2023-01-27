module PasswordLESS
  require "passwordLESS/configuration"
  require 'passwordLESS/gem/version'
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
      initiate_request('/api/send_otp', request_body)
    end

    def verify_otp(username, otp)
      request_body = { username: username, otp: otp }
      initiate_request('/api/verify_otp', request_body)
    end

    def verify_session(auth_token)
      request_body = { auth_token: auth_token }
      initiate_request('/api/verify_session', request_body)
    end

    def application_details(application_name)
      request_body = { application_name: application_name }
      initiate_request('/api/application_details', request_body, 'get')
    end

    def initiate_request(path, request_body, method = 'post')
      #passwordLESS domain
      domain_url = 'https://passwordless-authetication.herokuapp.com/'
      uri = URI.parse(domain_url + path)

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
      JSON.parse(response.body)
    end

    def api_key
      configuration.api_key
    end
  end
end