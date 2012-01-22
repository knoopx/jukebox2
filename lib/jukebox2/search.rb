module Jukebox2
  module Search
    PARAM_NAME = :search

    module ControllerMethods
      extend ActiveSupport::Concern

      module ClassMethods
        def apply_search
          scoped(:only => :index) do |target|
            target.scoped.scoped_search(params[PARAM_NAME])
          end
        end
      end
    end

    module Scope
      extend ActiveSupport::Concern

      class Chain
        def initialize(target, &block)
          @target = target
          yield(self)
        end

        def method_missing(method, *args, &block)
          @target = @target.send(method, *args, &block)
        end

        def target!
          @target
        end
      end

      module MongoidMethods
        def chain(&block)
          Chain.new(self, &block).target!
        end

        def scoped_search(params)
          params ||= {}
          self.chain do |target|
            search_scopes.each do |name|
              target.send(name, params[name]) unless params[name].blank?
            end
          end
        end
      end

      module ClassMethods
        def search_scope(name)
          search_scopes << name
        end

        def search_scopes
          @search_scopes ||= []
        end
      end

      included do
        Mongoid::Criteria.send(:include, MongoidMethods)
      end
    end
  end
end