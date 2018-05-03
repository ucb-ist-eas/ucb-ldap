require 'rubygems'
require 'net/ldap'
require 'time'

require "ucb_ldap/version"
require 'ucb_ldap/schema'
require 'ucb_ldap/schema_attribute'
require 'ucb_ldap/entry'
require 'ucb_ldap/person'
require 'ucb_ldap/expired_person'
require 'ucb_ldap/job_appointment'
require 'ucb_ldap/org'
require 'ucb_ldap/namespace'
require 'ucb_ldap/address'
require 'ucb_ldap/student_term'
require 'ucb_ldap/affiliation'
require 'ucb_ldap/service'


module UCB
  #:nodoc:
  #
  # =UCB::LDAP
  #
  # <b>If you are doing searches that don't require a privileged bind
  # and are accessing the default (production) server
  # you probably don't need to call any of the methods in this module.</b>
  #
  # Methods in this module are about making <em>connections</em>
  # to the LDAP directory.
  #
  # Interaction with the directory (searches and updates) is usually through the search()
  # and other methods of UCB::LDAP::Entry and its sub-classes.
  #
  module LDAP

    BadAttributeNameException = Class.new(Exception) #:nodoc:

    class BindFailedException < Exception #:nodoc:
      def initialize
        super("Failed to bind username '#{UCB::LDAP.username}' to '#{UCB::LDAP.host}'")
      end
    end

    class ConnectionFailedException < Exception #:nodoc:
      def initialize
        super("Failed to connect to ldap host '#{UCB::LDAP.host}''")
      end
    end

    class DirectoryNotUpdatedException < Exception #:nodoc:
      def initialize
        result = UCB::LDAP.net_ldap.get_operation_result
        super("(Code=#{result.code}) #{result.message}")
      end
    end


    HOST_PRODUCTION = 'nds.berkeley.edu'
    HOST_TEST = 'nds-test.berkeley.edu'

    class << self
      # Execute UCB::LDAP commands with a different username and password.
      # Original credentials are restored.
      def with_credentials(username_to_use, password_to_use)
        original_username = username
        original_password = password

        UCB::LDAP.authenticate(username_to_use, password_to_use)

        yield
      ensure
        UCB::LDAP.authenticate(original_username, original_password)
      end

      ##
      # Give (new) bind credentials to LDAP.  An attempt will be made
      # to bind and will raise BindFailedException if bind fails.
      #
      # Call clear_authentication() to remove privileged bind.
      #
      def authenticate(username, password)
        @username, @password = username, password
        new_net_ldap() # to force bind()
      end

      ##
      # Removes current bind (username, password).
      #
      def clear_authentication
        authenticate(nil, nil)
      end

      ##
      # Returns LDAP host used for lookups.  Default is HOST_PRODUCTION.
      #
      def host
        @host || HOST_PRODUCTION
      end

      ##
      # Setter for #host.
      #
      # Note: validation of host is deferred until a search is performed
      # or #authenticate() is called at which time a bad host will
      # raise ConnectionFailedException.
      #---
      # Don't want to reconnect unless host really changed.
      #
      def host=(host)
        if host != @host
          @host = host
          @net_ldap = nil
        end
      end

      ##
      # Returns Net::LDAP instance that is used by UCB::LDAP::Entry
      # and subclasses for directory searches.
      #
      # You might need this to perform searches not supported by
      # sub-classes of Entry.
      #
      # Note: callers should not cache the results of this call unless they
      # are prepared to handle timed-out connections (which this method does).
      #
      def net_ldap
        @net_ldap ||= new_net_ldap
      end

      def password #:nodoc:
        @password
      end

      def username #:nodoc:
        @username
      end

      ##
      # If you are using UCB::LDAP in a Rails application you can specify binds on a
      # per-environment basis, just as you can with database credentials.
      #
      #   # in ../config/ldap.yml
      #
      #   development:
      #     username: user_dev
      #     password: pass_dev
      #
      #   # etc.
      #
      #
      #   # in ../config/environment.rb
      #
      #   require 'ucb_ldap'
      #   UCB::LDAP.bind_for_rails()
      #
      # Runtime error will be raised if bind_file not found or if environment key not
      # found in bind_file.
      #
      def bind_for_rails(bind_file = "#{::Rails.root}/config/ldap.yml", environment = ::Rails.env)
        bind(bind_file, environment)
      end

      def bind(bind_file, environment)
        raise "Can't find bind file: #{bind_file}" unless FileTest.exists?(bind_file)
        binds = YAML.load(IO.read(bind_file))
        bind = binds[environment] || raise("Can't find environment=#{environment} in bind file")
        authenticate(bind['username'], bind['password'])
      end

      ##
      # Returns +arg+ as a Ruby +Date+ in local time zone.  Returns +nil+ if +arg+ is +nil+.
      #
      def local_date_parse(arg)
        arg.nil? ? nil : Date.parse(Time.parse(arg.to_s).localtime.to_s)
      end

      ##
      # Returns +arg+ as a Ruby +DateTime+ in local time zone.  Returns +nil+ if +arg+ is +nil+.
      #
      def local_datetime_parse(arg)
        arg.nil? ? nil : DateTime.parse(Time.parse(arg.to_s).localtime.to_s)
      end

      ## TODO: restore private
      # private unless $TESTING

      ##
      # The value of the :auth parameter for Net::LDAP.new.
      #
      def authentication_information
        password.nil? ?
            { :method => :anonymous } :
            { :method => :simple, :username => username, :password => password }
      end

      ##
      # Returns +true+ if connection simple search works.
      #
      def ldap_ping
        search_attrs = {
            :base => "",
            :scope => Net::LDAP::SearchScope_BaseObject,
            :attributes => [1.1]
        }
        result = false
        @net_ldap.search(search_attrs) { result = true }
        result
      end

      ##
      # Returns new Net::LDAP instance.
      #
      def new_net_ldap
        params = {
            :host => host,
            :auth => authentication_information,
            :port => 636,
            :encryption => { :method => :simple_tls }
        }
        @net_ldap = Net::LDAP.new(params)
        @net_ldap.bind || raise(BindFailedException)
        @net_ldap
      rescue Net::LDAP::Error => e
        raise(BindFailedException)
      end

      ##
      # Used for testing
      #
      def clear_instance_variables
        @host = nil
        @net_ldap = nil
        @username = nil
        @password = nil
      end
    end
  end
end
