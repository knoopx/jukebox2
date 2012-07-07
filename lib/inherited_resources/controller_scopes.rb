module InheritedResources
  module ControllerScopes
    extend ActiveSupport::Concern

    included do
      alias_method_chain :apply_scopes, :controller_scopes
    end

    def apply_controller_scopes(target)
      self.class.scopes.each do |scope|
        target = scope.execute(self, target) if scope.execute?(self)
      end
      target
    end

    def apply_scopes_with_controller_scopes(target, hash = params)
      apply_scopes_without_controller_scopes(apply_controller_scopes(target), hash)
    end

    module ClassMethods
      class ControllerScope
        attr_reader :opts, :block

        def initialize(opts = {}, block)
          opts.assert_valid_keys(:only, :except)
          @opts, @block = opts, block
        end

        def execute(controller, target)
          controller.instance_exec(target, &@block)
        end

        def execute?(controller)
          only = Array.wrap(@opts[:only])
          except = Array.wrap(@opts[:except])

          if only.empty?
            except.empty? || !except.include?(controller.action_name.to_sym)
          else
            only.include?(controller.action_name.to_sym)
          end
        end
      end

      def scopes
        @scopes ||= []
      end

      def scoped(opts = {}, &block)
        scopes << ControllerScope.new(opts, block)
      end
    end
  end
end