require 'on_destroy'

module OnDestroy
  class Railtie < Rails::Railtie
    initializer "on_destroy.active_record" do
      ActiveSupport.on_load(:active_record) do
        # ActiveRecord::Base gets new behavior
        include OnDestroy::Model
      end
    end
  end
end
