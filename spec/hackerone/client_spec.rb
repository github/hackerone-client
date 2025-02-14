# frozen_string_literal: true

require "spec_helper"
require "time"

RSpec.describe HackerOne::Client do
  let(:point_in_time) { DateTime.parse("2017-02-11T16:00:44-10:00") }
  # Remove this let definition as it conflicts with the one in the report context
  # let(:api) { HackerOne::Client::Api.new("github") }

  context "configuration" do
    it "raises error when no credentials are available" do
      ENV["HACKERONE_TOKEN"] = nil
      ENV["HACKERONE_TOKEN_NAME"] = nil
      
      client = HackerOne::Client::Api.new("github")
      expect {
        client.report(200)
      }.to raise_error(HackerOne::Client::NotConfiguredError)
    end

    it "rejects invalid range values for risk classification" do
      begin
        expect { HackerOne::Client.low_range = "fred" }.to raise_error(ArgumentError)
        expect { HackerOne::Client.low_range = nil }.to raise_error(ArgumentError)
        expect { HackerOne::Client.low_range = 1..10000 }.to_not raise_error
      ensure
        HackerOne::Client.low_range = HackerOne::Client::DEFAULT_LOW_RANGE
      end
    end

    it "initializes successfully with explicit credentials" do
      client = HackerOne::Client::Api.new("github", token: "mytoken", token_name: "myname")
      expect(client.instance_variable_get(:@token)).to eq("mytoken")
      expect(client.instance_variable_get(:@token_name)).to eq("myname")
    end

    it "falls back to ENV vars when no explicit credentials given" do
      ENV["HACKERONE_TOKEN"] = "envtoken"
      ENV["HACKERONE_TOKEN_NAME"] = "envname"
      
      client = HackerOne::Client::Api.new("github")
      expect(client.instance_variable_get(:@token)).to eq("envtoken")
      expect(client.instance_variable_get(:@token_name)).to eq("envname")
    ensure
      ENV["HACKERONE_TOKEN"] = nil
      ENV["HACKERONE_TOKEN_NAME"] = nil
    end

  end

  context "#report" do
    # This setup should work with the VCR cassette
    let(:api) { HackerOne::Client::Api.new("github", token: "bar", token_name: "foo") }

    it "fetches and populates a report" do
      # Add debug to verify credentials
      puts "Debug: token=#{api.instance_variable_get(:@token)}, token_name=#{api.instance_variable_get(:@token_name)}"
      
      VCR.use_cassette(:report) do
        report = api.report(200)
        expect(report).to_not be_nil
      end
    end

    it "raises an exception if a report is not found" do
      VCR.use_cassette(:missing_report) do
        expect { api.report(404) }.to raise_error(ArgumentError)
      end
    end

    it "raises an error if hackerone 500s" do
      VCR.use_cassette(:server_error) do
        expect { api.report(500) }.to raise_error(RuntimeError)
      end
    end
  end

  context "#create_report" do
    let(:api) { HackerOne::Client::Api.new("github", token: "foo", token_name: "bar") }

    it "raises an error if no program is supplied" do
      expect {
        HackerOne::Client::Api.new.create_report(title: "hi", summary: "hi", impact: "string", severity_rating: "none", source: "api")
      }.to raise_error(ArgumentError)
    end

    it "creates a new report" do
      VCR.use_cassette(:create_report) do
        report = api.create_report(
          title: "hi",
          summary: "hi",
          impact: "string",
          severity_rating: "none",
          source: "api"
        )
        expect(report).to_not be_nil
        expect(report).to be_kind_of(HackerOne::Client::Report)
      end
    end

    it "raises an error if report was not created" do
      VCR.use_cassette(:create_report_invalid) do
        expect {
          api.create_report(title: "hi", summary: "hi", impact: "string", severity_rating: "invalid_severity", source: "api")
        }.to raise_error(ArgumentError)
      end
    end
  end

  context "#reports" do
    let(:api) { HackerOne::Client::Api.new("github", token: "foo", token_name: "bar") }
    
    it "raises an error if no program is supplied" do
      expect { HackerOne::Client::Api.new.reports }.to raise_error(ArgumentError)
    end

    it "returns new reports for a default program as default" do
      begin
        HackerOne::Client.program = "github"
        VCR.use_cassette(:report_list) do
          expect(HackerOne::Client::Api.new.reports(since: point_in_time)).to_not be_empty
        end
      ensure
        HackerOne::Client.program = nil
      end
    end

    it "returns new reports for a given program as default" do
      VCR.use_cassette(:report_list) do
        reports = api.reports(since: point_in_time)
        expect(reports).to_not be_empty
        expect(reports.first).to be_kind_of(HackerOne::Client::Report)
      end
    end

    it "returns an empty array if no reports are found" do
      VCR.use_cassette(:empty_report_list) do
        expect(api.reports(since: point_in_time)).to be_empty
      end
    end

    it "returns triaged reports for a default program" do
      begin
        HackerOne::Client.program = "github"
        VCR.use_cassette(:report_list_triaged) do
          expect(HackerOne::Client::Api.new.reports(since: point_in_time, state: :triaged)).to_not be_empty
        end
      ensure
        HackerOne::Client.program = nil
      end
    end

    it "returns triaged reports for a given program" do
      VCR.use_cassette(:report_list_triaged) do
        expect(api.reports(since: point_in_time, state: :triaged)).to_not be_empty
      end
    end

    it "returns reports created before a certain date" do
      VCR.use_cassette(:report_list_before) do
        reports = api.reports(before: point_in_time, since: nil)
        expect(reports).to_not be_empty
        reports.map(&:created_at).each do |r|
          expect(Time.parse(r)).to be < point_in_time
        end
      end
    end
  end
end
