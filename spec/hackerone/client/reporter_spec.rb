# frozen_string_literal: true

require "spec_helper"

RSpec.describe HackerOne::Client::Report do
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

  let(:reporters) do
    VCR.use_cassette(:reporters) do
      api.reporters
    end
  end

  let(:reporter) do
    reporters.first
  end

  it "returns a collection" do
    expect(reporters).to be_kind_of(Array)
    expect(reporters.size).to eq(2)
  end

  it "returns id" do
    expect(reporter.id).to be_present
    expect(reporter.id).to eq("3683")
  end

  it "returns disabled?" do
    expect(reporter.disabled?).to eq(false)
  end

  it "returns username" do
    expect(reporter.username).to eq("demo-hacker")
  end

  it "returns name" do
    expect(reporter.name).to eq("Demo Hacker")
  end
end
