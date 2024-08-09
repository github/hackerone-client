# frozen_string_literal: true

module HackerOne
  module Client
    class Organization
      include ResourceHelper

      delegate :handle, :created_at, :updated_at, to: :attributes

      def initialize(org)
        @organization = org
      end

      def id
        @organization[:id]
      end

      def assets(page_number: 1, page_size: 100)
        make_get_request(
          "organizations/#{id}/assets",
          params: { page: { number: page_number, size: page_size } }
        ).map do |asset_data|
          Asset.new(asset_data, self)
        end
      end

      private

      def attributes
        OpenStruct.new(@organization[:attributes])
      end
    end
  end
end
