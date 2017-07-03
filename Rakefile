require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc "Run unit rspecs"
RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = "--color"
  t.pattern = 'spec/unit/**{,/*/**}/*_spec.rb'
end
task :spec => :unit
task :default => :spec
