require 'rubygems'
require 'rake'
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "memento"
    gem.summary = %Q{Undo for Rails/ActiveRecord - covers destroy, update and create}
    gem.email = "sebastian@yo.lk"
    gem.homepage = "http://github.com/yolk/memento"
    gem.authors = ["Yolk Sebastian Munz & Julia Soergel GbR"]

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new  
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

