require 'rails/generators'
require 'rails/generators/active_record'

class MementoMigrationGenerator < Rails::Generators::Base
  include ::Rails::Generators::Migration
  include ActiveRecord::Generators::Migration

  source_root File.expand_path '../templates', __FILE__

  def add_memento_migration
    migration_template "migration.rb", 'db/migrate/memento_migration.rb'
  end

end
