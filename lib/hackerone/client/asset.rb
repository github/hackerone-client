# frozen_string_literal: true

module HackerOne
  module Client
    class Asset
      include ResourceHelper

      DELEGATES = [
        :asset_type,
        :identifier,
        :description,
        :coverage,
        :max_severity,
        :confidentiality_requirement,
        :integrity_requirement,
        :availability_requirement,
        :created_at,
        :updated_at,
        :archived_at,
        :reference,
        :state,
      ]

      delegate *DELEGATES, to: :attributes

      attr_reader :organization

      def initialize(asset, organization)
        @asset = asset
        @organization = organization
      end

      def id
        @asset[:id]
      end

      def update(attributes:)
        body = {
          type: "asset",
          attributes: attributes
        }
        make_put_request("organizations/#{organization.id}/assets/#{id}", request_body: body)
      end

      def programs
        relationships.programs[:data].map { |p| Program.new(p) }
      end

      private

      def relationships
        OpenStruct.new(@asset[:relationships])
      end

      def attributes
        OpenStruct.new(@asset[:attributes])
      end
    end
  end
end
