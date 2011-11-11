module InheritedResources
  module AutoAssignCurrentUser
    extend ActiveSupport::Concern

    included do
      def create_resource_with_current_user(obj)
        obj.send(:user=, current_user) if current_user.present? and obj.respond_to?(:user=)
        create_resource_without_current_user(obj)
      end

      alias_method_chain :create_resource, :current_user
    end
  end
end