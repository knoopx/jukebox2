module Jukebox2
  module Pagination
    module ControllerMethods
      extend ActiveSupport::Concern

      module ClassMethods
        def apply_pagination(opts = {})
          scoped(opts.merge(:only => :index)) do |target|
            target.page(params.fetch(:page, 1))
          end
        end
      end
    end
  end
end