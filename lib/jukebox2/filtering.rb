module Jukebox2
  module Filtering
    FILTER_PARAM_NAME = :filter

    module Helpers
      def filter(*attrs)
        navigation(:class => "pills pull-right", :namespace => FILTER_PARAM_NAME) do |n|
          attrs.each do |attr|
            n.send(attr, link_to(attr.to_s.humanize, params.merge(FILTER_PARAM_NAME => attr)))
          end
        end
      end
    end

    module ControllerMethods
      extend ActiveSupport::Concern

      included do
        helper_method :current_filter
      end

      module InstanceMethods
        def current_filter
          params[FILTER_PARAM_NAME].try(:to_sym)
        end
      end

      module ClassMethods
        def apply_filtering
          scoped(:only => :index) do |target|
            if current_filter.present? and target.respond_to?(current_filter)
              set_current_tab(current_filter, FILTER_PARAM_NAME)
              target.send(current_filter)
            else
              set_current_tab(:default, FILTER_PARAM_NAME)
              target
            end
          end
        end
      end
    end
  end
end