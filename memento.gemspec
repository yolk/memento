# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "memento/version"

Gem::Specification.new do |s|
  s.name = "memento"
  s.version = Memento::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Yolk Sebastian Munz & Julia Soergel GbR"]
  s.email = %q{sebastian@yo.lk}
  s.homepage = %q{http://github.com/yolk/memento}
  s.summary = %q{Undo for Rails/ActiveRecord - covers destroy, update and create}
  s.description = %q{Undo for Rails/ActiveRecord - covers destroy, update and create}

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activerecord',        '>= 3.2.5'
  s.add_dependency 'actionpack',          '>= 3.2.5'

  s.add_development_dependency 'rspec',   '>= 2.4.0'
  s.add_development_dependency 'sqlite3', '>= 1.3.5'
end

