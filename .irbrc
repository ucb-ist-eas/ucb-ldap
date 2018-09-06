if File.exists?("spec/ldap_config.yml")
  puts "Note from local .irbrc:"
  puts "Loading and configuring LDAP config from spec/ldap_config.yml"
  puts "This is using ucb_ldap as an installed gem - this might not be what you want."
  require "rubygems"
  require "yaml"
  require "ucb_ldap"
  config = YAML.load(IO.read("spec/ldap_config.yml"))["ldap"]
  UCB::LDAP.initialize(config["username"], config["password"], config["host"])
  UCB::LDAP::Person.include_test_entries = config["include_test_entries"]
end
