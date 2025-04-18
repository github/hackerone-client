# frozen_string_literal: true

require "bundler/setup"
require "hackerone/client"
require "pry"
require "vcr"
require "webmock/rspec"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock

  config.register_request_matcher :uri_ignoring_array_indexes do |request1, request2|
    uri1 = URI(request1.uri)
    uri2 = URI(request2.uri)

    uri1.scheme == uri2.scheme &&
    uri1.host == uri2.host &&
    uri1.path == uri2.path &&
    CGI.parse(uri1.query.to_s).transform_values(&:sort) == CGI.parse(uri2.query.to_s).transform_values(&:sort)
  end

  config.default_cassette_options = {
    match_requests_on: [:method, :uri_ignoring_array_indexes]
  }
end
