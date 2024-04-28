module ModelExplorer
  module Scopes
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    module ClassMethods
      def scope(name, body)
        if body&.respond_to?(:parameters) && body.parameters.blank?
          (@_model_explorer_scopes ||= []) << name
        end

        super
      end

      def model_explorer_scopes
        @_model_explorer_scopes || []
      end
    end
  end
end
