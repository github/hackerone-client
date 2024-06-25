# frozen_string_literal: true

module HackerOne
  module Client
    class StructuredScope
      include ResourceHelper

      DELEGATES = [
        :asset_identifier,
        :asset_type,
        :eligible_for_bounty,
        :eligible_for_submission,
        :instruction,
        :max_severity,
        :reference
      ]

      delegate *DELEGATES, to: :attributes

      def initialize(program_id, scope)
        @program_id = program_id
        @scope = scope
      end

      def id
        @scope[:id]
      end

      def program_id
        @program_id
      end

      def update(attributes:)
        body = {
          type: "structured-scope",
          attributes: attributes
        }
        make_put_request("programs/#{@program_id}/structured_scopes/#{id}", request_body: body)
      end

      private

      def attributes
        OpenStruct.new(@scope[:attributes])
      end
    end
  end
end
