# frozen_string_literal: true

require "spec_helper"

RSpec.describe HackerOne::Client::User do
  let(:api) { HackerOne::Client::Api.new("github", token: "bar", token_name: "foo") }

  before(:each) do
    # Initialize the API client before running tests
    api
  end

  after(:each) do
    # Clear both cached programs and configuration
    HackerOne::Client.instance_variable_set(:@token, nil)
    HackerOne::Client.instance_variable_set(:@token_name, nil)
  end

  describe "find" do
    it "returns a user" do
      user = VCR.use_cassette(:user_find_fransrosen) do
        described_class.find "fransrosen"
      end

      expect(user.reputation).to eq 15033
      expect(user.signal).to be_within(0.1).of(6.4)
      expect(user.impact).to be_within(0.1).of(22.6)
      expect(user.username).to eq "fransrosen"
    end
  end
end
