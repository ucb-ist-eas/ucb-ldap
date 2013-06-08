
begin
  require "bundler/gem_tasks"
  require 'bundler/setup'
rescue LoadError => e
  require('rubygems') && retry
  puts "Please `gem install bundler' and run `bundle install' to ensure you have all dependencies"
  raise e
end


require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--color', "--format documentation"]
end
