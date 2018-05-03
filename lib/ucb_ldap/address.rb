
module UCB
  module LDAP
    # = UCB::LDAP::Address
    #
    # This class models a person address instance in the UCB LDAP directory.
    #
    #   a = Address.find_by_uid("1234")       #=> [#<UCB::LDAP::Address: ...>, ...]
    #
    # Addresses are usually loaded through a Person instance:
    #
    #   p = Person.find_by_uid("1234")    #=> #<UCB::LDAP::Person: ...>
    #   addrs = p.addresses               #=> [#<UCB::LDAP::Address: ...>, ...]
    #
    # == Note on Binds
    #
    # You must have a privileged bind and pass your credentials to UCB::LDAP.authenticate()
    # before performing your Address search.
    #
    class Address < Entry
      @entity_name = 'personAddress'

      def primary_work_address?
        berkeleyEduPersonAddressPrimaryFlag
      end

      def address_type
        warn "DEPRECATED: address_type is no longer supported"
        []
      end

      def building_code
        warn "DEPRECATED: building_code is no longer supported"
        []
      end

      def city
        l.first
      end

      def country_code
        warn "DEPRECATED: country_code is no longer supported"
        []
      end

      def department_name
        warn "DEPRECATED: department_name is no longer supported"
        []
      end

      def department_acronym
        berkeleyEduPersonAddressUnitHRDeptName
      end

      def directories
        warn "DEPRECATED: directories is no longer supported"
        []
      end

      # Returns email address associated with this Address.
      def email
        mail.first
      end

      def mail_code
        berkeleyEduPersonAddressMailCode
      end

      def mail_release?
        berkeleyEduEmailRelFlag
      end

      def phone
        telephoneNumber.first
      end

      # Returns postal address as an Array.
      #
      #   addr.attribute(:postalAddress) #=> '501 Banway Bldg.$Berkeley, CA 94720-3814$USA'
      #   addr.postal_address            #=> ['501 Banway Bldg.', 'Berkeley, CA 94720-3814', 'USA']
      #
      def postal_address
        postalAddress == [] ? nil : postalAddress.split("$")
      end

      def sort_order
        warn "DEPRECATED: sort_order is no longer supported"
        0
      end

      def state
        st.first
      end

      def zip
        postalCode
      end

      class << self
        # Returns an Array of Address for <tt>uid</tt>, sorted by sort_order().
        # Returns an empty Array ([]) if nothing is found.
        #
        def find_by_uid(uid)
          warn "DEPRECATED: Addresses are no longer supported by LDAP. This method will always return an empty Array"
          []
        end

      end
    end
  end
end
