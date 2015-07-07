module Memento
  class Railtie < Rails::Railtie
    generators do
      require File.join File.dirname(__FILE__), '..', '..', 'generators', 'memento_migration', 'memento_migration_generator'
    end
  end
end if defined?(Rails)
