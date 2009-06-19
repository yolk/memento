# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{memento}
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yolk Sebastian Munz & Julia Soergel GbR"]
  s.date = %q{2009-06-19}
  s.email = %q{sebastian@yo.lk}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "generators/memento_migration/memento_migration_generator.rb",
    "generators/memento_migration/templates/migration.rb",
    "lib/memento.rb",
    "lib/memento/action.rb",
    "lib/memento/action/create.rb",
    "lib/memento/action/destroy.rb",
    "lib/memento/action/update.rb",
    "lib/memento/action_controller_methods.rb",
    "lib/memento/active_record_methods.rb",
    "lib/memento/result.rb",
    "lib/memento/session.rb",
    "lib/memento/state.rb",
    "rails/init.rb",
    "spec/memento/action/create_spec.rb",
    "spec/memento/action/destroy_spec.rb",
    "spec/memento/action/update_spec.rb",
    "spec/memento/action_controller_methods_spec.rb",
    "spec/memento/active_record_methods_spec.rb",
    "spec/memento/result_spec.rb",
    "spec/memento/session_spec.rb",
    "spec/memento/state_spec.rb",
    "spec/memento_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/yolk/memento}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Undo for Rails/ActiveRecord - covers destroy, update and create}
  s.test_files = [
    "spec/memento/action/create_spec.rb",
    "spec/memento/action/destroy_spec.rb",
    "spec/memento/action/update_spec.rb",
    "spec/memento/action_controller_methods_spec.rb",
    "spec/memento/active_record_methods_spec.rb",
    "spec/memento/result_spec.rb",
    "spec/memento/session_spec.rb",
    "spec/memento/state_spec.rb",
    "spec/memento_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
