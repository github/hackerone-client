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

      def initialize(organization_id, asset)
        @organization_id = organization_id
        @asset = asset
      end

      def id
        @asset[:id]
      end

      def organization_id
        @organization_id
      end

      def update(attributes:)
        body = {
          type: "asset",
          attributes: attributes
        }
        make_put_request("organizations/#{@organization_id}/assets/#{id}", request_body: body)
      end

      def programs
        relationships.programs[:data].map{ Program.new(_1) }
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
