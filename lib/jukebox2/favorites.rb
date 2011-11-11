module Jukebox2
  module Favorites
    module ModelMethods
      extend ActiveSupport::Concern

      included do
        scope :favorited, where { favorited_at != nil }

        def favorited?
          !favorited_at.nil?
        end
      end
    end
    module ControllerMethods
      extend ActiveSupport::Concern

      included do
        has_scope :favorited
      end

      def toggle_favorite
        if resource.favorited_at.nil?
          resource.touch(:favorited_at)
        else
          resource.update_attribute(:favorited_at, nil)
        end

        render(:update) { |page| page["##{dom_id(resource, :favorite)}"].replaceWith(favorite_button(resource)) }
      end
    end
  end
end