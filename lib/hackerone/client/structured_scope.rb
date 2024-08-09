# frozen_string_literal: true

module HackerOne
  module Client
    class StructuredScope
      include ResourceHelper

      DELEGATES = [
        :asset_identifier,
        :asset_type,
        :availability_requirement,
        :confidentiality_requirement,
        :eligible_for_bounty,
        :eligible_for_submission,
        :instruction,
        :integrity_requirement,
        :max_severity,
        :reference
      ]

      delegate *DELEGATES, to: :attributes

      attr_reader :program

      def initialize(scope, program = nil)
        @program = program
        @scope = scope
      end

      def id
        @scope[:id]
      end

      def update(attributes:)
        body = {
          type: "structured-scope",
          attributes: attributes
        }
        make_put_request("programs/#{program.id}/structured_scopes/#{id}", request_body: body)
      end

      private

      def attributes
        OpenStruct.new(@scope[:attributes])
      end
    end
  end
end
