class MementoMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template("migration.rb", 'db/migrate',
                           :assigns => {  },
                           :migration_file_name => "memento_migration"
                           )
    end
  end
end