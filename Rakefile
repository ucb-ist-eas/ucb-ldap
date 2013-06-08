require 'yaml'

begin
  require "bundler/gem_tasks"
  require 'bundler/setup'
rescue LoadError => e
  require('rubygems') && retry
  puts "Please `gem install bundler' and run `bundle install' to ensure you have all dependencies"
  raise e
end

Bundler::GemHelper.install_tasks


require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--color', "--format documentation"]
end

desc "Update schema file"
task :update_schema_file do
  print 'rebuilding schema file ... '
  $:.unshift(File.dirname(__FILE__) + '/../lib')
  require 'ucb_ldap'
  include UCB::LDAP
  File.open(Schema.schema_file, "w") do |file|
    file.print Schema.yaml_from_url
  end
  puts 'done'
end
task :package => :update_schema_file
task :repackage => :update_schema_file


#desc "Performance tests"
#task :perf do
#  require 'test/performance/_run_all'
#end
