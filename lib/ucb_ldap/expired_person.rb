
module UCB::LDAP
  ## =UCB::LDAP::ExpiredPerson
  #
  # Class for accessing the Expired People tree of the UCB LDAP directory.
  # Identical in every way to Person[rdoc-ref:Person] apart from binding.
  #
  class ExpiredPerson < Person

    @entity_name = 'person'
    @tree_base = 'ou=expired people,dc=berkeley,dc=edu'

    ##
    # Returns expired status
    #
    # True by definition for expired users
    #
    def expired?
      true
    end

  end
end
