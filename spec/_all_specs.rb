# Runs all RSpec files
Dir["#{File.dirname(__FILE__)}/*_spec.rb"].each do |spec_file|
  require spec_file
end
