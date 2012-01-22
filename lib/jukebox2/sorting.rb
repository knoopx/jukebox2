module Jukebox2
  module Sorting
    DIRECTIONS = [:asc, :desc]
    INVERSE_DIRECTION = {:asc => :desc, :desc => :asc}
    DIRECTION_ICON = {:asc => "e016", :desc => "e014"}
    ATTRIBUTE_PARAM_NAME = :sort
    DIRECTION_PARAM_NAME = :dir

    module Helpers
      extend ActiveSupport::Concern

      module InstanceMethods
        def sort_link(attribute)
          label = attribute.to_s.humanize

          if current_sort_attribute == attribute
            label = [iconic(DIRECTION_ICON[current_sort_direction]), label].join(" ")
            direction = INVERSE_DIRECTION[current_sort_direction]
          end

          link_to label.html_safe, params.deep_merge(ATTRIBUTE_PARAM_NAME => attribute, DIRECTION_PARAM_NAME => direction)
        end
      end
    end

    module ControllerMethods
      extend ActiveSupport::Concern

      included do
        helper_method :current_sort_attribute
        helper_method :current_sort_direction
        helper_method :default_sort_attribute
        helper_method :default_sort_direction
      end

      module InstanceMethods
        def current_sort_attribute
          params[ATTRIBUTE_PARAM_NAME].try(:to_sym) || default_sort_attribute
        end

        def current_sort_direction
          params[DIRECTION_PARAM_NAME].try(:to_sym) || default_sort_direction
        end

        def default_sort_attribute
          self.class.default_sort_attribute
        end

        def default_sort_direction
          self.class.default_sort_direction
        end
      end

      module ClassMethods
        def apply_sorting
          scoped(:only => :index) do |target|
            direction = current_sort_direction || default_sort_direction
            attribute = current_sort_attribute || default_sort_attribute

            if DIRECTIONS.include?(direction) and not attribute.blank?
              target.send(direction, attribute)
            else
              target
            end
          end
        end

        def set_default_sort_attribute(attr)
          @default_sort_attr = attr
        end

        def set_default_sort_direction(direction)
          @default_sort_dir = direction
        end

        def default_sort_attribute
          @default_sort_attr
        end

        def default_sort_direction
          @default_sort_dir || :asc
        end
      end
    end
  end
end