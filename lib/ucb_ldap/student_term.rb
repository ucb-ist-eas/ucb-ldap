module UCB
  module LDAP
    # = UCB::LDAP::StudentTerm
    #
    # This class models a student's term entries in the UCB LDAP directory.
    #
    #   terms = StudentTerm.find_by_uid("1234")       #=> [#<UCB::LDAP::StudentTerm: ...>, ...]
    #
    # StudentTerms are usually loaded through a Person instance:
    #
    #   p = Person.find_by_uid("1234")    #=> #<UCB::LDAP::Person: ...>
    #   terms = p.student_terms        #=> [#<UCB::LDAP::StudentTerm: ...>, ...]
    #
    # == Note on Binds
    #
    # You must have a privileged bind and pass your credentials to UCB::LDAP.authenticate()
    # before performing your StudentTerm search.
    #
    class StudentTerm < Entry
      @entity_name = 'personStudentTerm'

      def change_datetime
        warn "DEPRECATED: change_datetime is no longer supported"
        []
      end

      def college_code
        warn "DEPRECATED: college_code is no longer supported"
        []
      end

      def college_name
        warn "DEPRECATED: college_name is no longer supported"
        []
      end

      def level_code
        warn "DEPRECATED: level_code is no longer supported"
        []
      end

      def level_name
        warn "DEPRECATED: level_name is no longer supported"
        []
      end

      def role_code
        warn "DEPRECATED: role_code is no longer supported"
        []
      end

      def role_name
        warn "DEPRECATED: role_name is no longer supported"
        []
      end

      def major_code
        warn "DEPRECATED: major_code is no longer supported"
        []
      end

      def major_name
        warn "DEPRECATED: major_name is no longer supported"
        []
      end

      def registration_status_code
        warn "DEPRECATED: registration_status_code is no longer supported"
        []
      end

      def registration_status_name
        warn "DEPRECATED: registration_status_name is no longer supported"
        []
      end

      def term_code
        warn "DEPRECATED: term_code is no longer supported"
        []
      end

      def term_name
        warn "DEPRECATED: term_name is no longer supported"
        []
      end

      def term_status
        warn "DEPRECATED: term_status is no longer supported"
        []
      end

      def term_year
        warn "DEPRECATED: term_year is no longer supported"
        []
      end

      def under_graduate_code
        warn "DEPRECATED: under_graduate_code is no longer supported"
        []
      end

      ##
      # Returns an Array of JobAppointment for <tt>uid</tt>, sorted by
      # record_number().
      # Returns an empty Array ([]) if nothing is found.
      #
      def self.find_by_uid(uid)
        warn "DEPRECATED: Student Terms are no longer supported by LDAP. This method always returns an empty Array"
        []
      end

    end
  end
end
