module Jukebox2
  module Favorites
    module ModelMethods
      extend ActiveSupport::Concern

      included do
        scope :favorited, excludes(:favorited_at => nil).desc(:favorited_at)

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
          resource.update_attribute(:favorited_at, DateTime.now)
        else
          resource.update_attribute(:favorited_at, nil)
        end

        render(:update) { |page| page["##{dom_id(resource, :favorite)}"].replaceWith(favorite_link(resource, params[:options])) }
      end
    end
  end
end