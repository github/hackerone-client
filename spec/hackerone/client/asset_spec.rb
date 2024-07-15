# frozen_string_literal: true

require "spec_helper"

RSpec.describe HackerOne::Client::Asset do
  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end
  before(:each) do
    stub_request(:get, "https://api.hackerone.com/v1/programs/18969").
      to_return(body: <<~JSON)
{
  "data": {
    "id": "18969",
    "type": "program",
    "attributes": {
      "handle": "github",
      "created_at": "2016-02-02T04:05:06.000Z",
      "updated_at": "2016-02-02T04:05:06.000Z"
    },
    "relationships": {
      "organization": {
        "data": {
          "id": "14",
          "type": "organization",
          "attributes": {
            "handle": "api-example",
            "created_at": "2016-02-02T04:05:06.000Z",
            "updated_at": "2016-02-02T04:05:06.000Z"
          }
        }
      }
    }
  }
}
    JSON

    stub_request(:get, "https://api.hackerone.com/v1/organizations/14/assets?page%5Bnumber%5D=1&page%5Bsize%5D=100").
      to_return(body:<<~JSON2)
{
  "data": [
    {
      "id": "2",
      "type": "asset",
      "attributes": {
        "asset_type": "domain",
        "domain_name": "hackerone.com",
        "description": null,
        "coverage": "untested",
        "max_severity": "critical",
        "confidentiality_requirement": "high",
        "integrity_requirement": "high",
        "availability_requirement": "high",
        "created_at": "2016-02-02T04:05:06.000Z",
        "updated_at": "2016-02-02T04:05:06.000Z",
        "archived_at": "2017-02-02T04:05:06.000Z",
        "reference": "reference",
        "state": "confirmed"
      },
      "relationships": {
        "asset_tags": {
          "data": [
            {
              "id": "1",
              "type": "asset-tag",
              "attributes": {
                "name": "test"
              },
              "relationships": {
                "asset_tag_category": {
                  "data": {
                    "id": "2",
                    "type": "asset-tag-category",
                    "attributes": {
                      "name": "test"
                    }
                  }
                }
              }
            }
          ]
        },
        "programs": {
          "data": [
            {
              "id": "18969",
              "type": "program",
              "attributes": {
                "handle": "github",
                "name": "team name"
              }
            }
          ]
        },
        "attachments": {
          "data": [
            {
              "id": "1337",
              "type": "attachment",
              "attributes": {
                "expiring_url": "https://attachments.s3.amazonaws.com/G74PuDP6qdEdN2rpKNLkVwZF",
                "created_at": "2016-02-02T04:05:06.000Z",
                "file_name": "example.png",
                "content_type": "image/png",
                "file_size": 16115
              }
            }
          ]
        }
      }
    }
  ],
  "links": {}
}
    JSON2
  end

  after(:each) do
    # clear cached programs to prevent contaminatin between tests
    HackerOne::Client::Program.instance_variable_set(:@my_programs, nil)
  end

  let(:program) do
    VCR.use_cassette(:programs) do
      HackerOne::Client::Program.find("github")
    end
  end

  let(:organization) do
    program.organization
  end

  let(:assets) do
    organization.assets
  end

  let(:asset) { assets[0] }

  it "returns a collection" do
    expect(assets).to be_kind_of(Array)
    expect(assets.size).to eq(1)
  end

  it "returns id" do
    expect(asset.id).to be_present
    expect(asset.id).to eq("2")
  end

  it "returns organization" do
    expect(asset.organization).to be_present
    expect(asset.organization.id).to eq("14")
  end

  it "returns programs" do
    expect(asset.programs).to be_kind_of(Array)
    expect(asset.programs.first.id).to eq("18969")
  end

  it "updates the asset" do
    req = stub_request(:put, "https://api.hackerone.com/v1/organizations/14/assets/2").
      with { |r|
        r.body == <<~BODY.strip
          {"data":{"type":"asset","attributes":{"description":"This is the new description"}}}
        BODY
      }.
      to_return(body: "{}") # we are not using the response for now so not bothering to stub it properly

    asset.update(
      attributes: {
        description: "This is the new description"
      }
    )

    expect(req).to have_been_requested
  end
end
