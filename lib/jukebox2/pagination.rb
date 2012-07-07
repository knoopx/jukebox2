module Jukebox2
  module Pagination
    module ControllerMethods
      extend ActiveSupport::Concern

      module ClassMethods
        def apply_pagination(opts = {})
          scoped(opts.merge(:only => :index)) do |target|
            if parent?
              target
            else
              target.page(params.fetch(:page, 1))
            end
          end
        end
      end
    end
  end
end