module Jukebox2
  module Navigation
    extend ActiveSupport::Concern

    def current_tab?(name, namespace = :default)
      self.class.get_current_tab(namespace) == name.to_sym
    end

    def current_tab(namespace = :default)
      self.class.get_current_tab(namespace)
    end

    def default_tab
      controller_name.underscore.to_sym
    end

    def set_current_tab(name, namespace = :default)
      self.class.set_current_tab(name, namespace)
    end

    def set_default_tab
      set_current_tab(default_tab)
    end

    module ClassMethods
      def set_current_tab(name, namespace = :default)
        @@navigation ||= {}
        @@navigation[namespace] = name.to_sym
      end

      def get_current_tab(namespace = :default)
        @@navigation ||= {}
        @@navigation[namespace]
      end
    end

    included do
      helper_method :current_tab?
      helper_method :current_tab
      helper_method :default_tab
      before_filter :set_default_tab
    end
  end
end