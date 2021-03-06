module CurationConcerns
  # Including WithoutNamespace on a controller allows us to prepend the default namespace to the params[:id]
  module WithoutNamespace
    extend ActiveSupport::Concern

    included do
      prepend_before_action :normalize_identifier, except: [:index, :create, :new]
    end

    protected

      def normalize_identifier
        params[:id] = CurationConcerns::Noid.namespaceize(params[:id])
      end
  end
end
