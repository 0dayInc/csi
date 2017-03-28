# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rdoc/task'

RSpec::Core::RakeTask.new

task default: :spec
task test: :spec

RDoc::Task.new do |rdoc|
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_dir = 'rdoc'
end
