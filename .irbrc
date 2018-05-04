if File.exists?("spec/ldap_config.yml")
  require "rubygems"
  require "yaml"
  require "ucb_ldap"
  config = YAML.load(IO.read("spec/ldap_config.yml"))["ldap"]
  UCB::LDAP.initialize(config["username"], config["password"], config["host"])
  UCB::LDAP::Person.include_test_entries = config["include_test_entries"]
end
