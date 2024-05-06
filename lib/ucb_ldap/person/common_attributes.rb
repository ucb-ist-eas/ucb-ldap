module UCB
  module LDAP
    module CommonAttributes

      # Returns +true+ if the entry represents a test entry.
      def test?
        berkeleyEduTestIDFlag
      end

      def uid
        super.first
      end

      def firstname
        givenname.first
      end

      alias :first_name :firstname

      def lastname
        sn.first
      end

      alias :last_name :lastname

      def email
        mail.first
      end

      def officialemail
        berkeleyEduAlternateId.first
      end

      def phone
        telephoneNumber.first
      end

      # Returns +Array+ of Affiliation for this Person. Requires a bind with access to affiliations.
      # See UCB::LDAP.authenticate().
      def affiliate_affiliations
        @affiliate_affiliations ||= Affiliation.find_by_uid(uid)
      end

      # Returns +Array+ of Namespace for this Person.
      # Requires a bind with access to namespaces.
      # See UCB::LDAP.authenticate().
      def namespaces
        warn "DEPRECATED: this is no longer supported by LDAP. This method will always return an empty Array"
        []
      end

      # Returns +Array+ of Service for this Person.
      # Requires a bind with access to services.
      # See UCB::LDAP.authenticate().
      def services
        warn "DEPRECATED: this is no longer supported by LDAP. This method will always return an empty Array"
        []
      end

      # Returns +Array+ of Address for this Person.
      # Requires a bind with access to addresses.
      # See UCB::LDAP.authenticate().
      def addresses
        warn "DEPRECATED: use postalAddress from a Person entry"
        []
      end

    end
  end
end
