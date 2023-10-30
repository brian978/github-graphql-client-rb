# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Github
  module Http
    module Api
      # Schema detection for GraphQL
      class Schema
        def initialize(token, endpoint = ENDPOINT)
          @token = token
          @endpoint = endpoint
        end

        def grab
          uri = URI.parse(@endpoint)

          request = Net::HTTP::Get.new(uri)
          request.content_type = "application/json"
          request["Authorization"] = "Bearer #{@token}"

          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
            http.request(request)
          end

          response.body.to_s
        end
      end
    end
  end
end
