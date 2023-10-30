# frozen_string_literal: true

require_relative "api/schema"

module Github
  module Http
    # Client for interacting with Github's GraphQL API
    class Client
      VERSION = "0.1.0"
      ENDPOINT = "https://api.github.com/graphql"

      def initialize(bearer_token, endpoint = Client::ENDPOINT, schema_loader = nil)
        @bearer_token = bearer_token
        @uri = URI(endpoint)
        @schema_loader = schema_loader || Api::Schema.new(bearer_token, endpoint)
      end

      def org_projects(org)
        query = <<-GRAPHQL
          query organization ($login: String!, $afterProjId: String) {
              organization (login: $login) {
                  id
                  login
                  name
                  projectsV2(first: 25, after: $afterProjId) {
                      nodes {
                          id
                          number
                          title
                          teams(first: 100) {
                              nodes {
                                  id
                                  name
                                  members(first: 100) {
                                      nodes {
                                          id
                                          login
                                          name
                                          updatedAt
                                      }
                                  }
                              }
                          }
                      }
                      totalCount
                      pageInfo {
                          hasPreviousPage
                          startCursor
                          endCursor
                          hasNextPage
                      }
                  }
              }
          }
        GRAPHQL

        execute(query, { login: org })
      end

      private

      attr_reader :uri, :bearer_token

      def schema
        @schema ||= GraphQL::Schema.from_definition(@schema_loader.grab)
      end

      def http_client
        Net::HTTP.new(uri.host, uri.port).tap do |http|
          http.use_ssl = true if uri.scheme == "https"
        end
      end

      def build_request(query, variables)
        { query: query, variables: variables }.to_json
      end

      def build_headers
        { "Authorization" => "Bearer #{bearer_token}" }
      end

      def execute(query, variables)
        response = http_client.post(uri.path, build_request(query, variables), build_headers)
        JSON.parse(response.body)
      end
    end
  end
end
