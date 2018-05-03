module UCB
  module LDAP
    # = UCB::LDAP::JobAppointment
    #
    # This class models a person's job appointment instance in the UCB LDAP directory.
    #
    #   appts = JobAppontment.find_by_uid("1234")       #=> [#<UCB::LDAP::JobAppointment: ...>, ...]
    #
    # JobAppointments are usually loaded through a Person instance:
    #
    #   p = Person.find_by_uid("1234")    #=> #<UCB::LDAP::Person: ...>
    #   appts = p.job_appointments        #=> [#<UCB::LDAP::JobAppointment: ...>, ...]
    #
    # == Note on Binds
    #
    # You must have a privileged bind and pass your credentials to UCB::LDAP.authenticate()
    # before performing your JobAppointment search.
    #
    class JobAppointment < Entry
      @entity_name = 'personJobAppointment'

      def cto_code
        warn "DEPRECATED: cto_code is no longer supported"
        []
      end

      def deptid
        warn "DEPRECATED: deptid is no longer supported"
        []
      end

      def record_number
        warn "DEPRECATED: record_number is no longer supported"
        []
      end

      def personnel_program_code
        warn "DEPRECATED: personnel_program_code is no longer supported"
        []
      end

      def primary?
        warn "DEPRECATED: primary? is no longer supported"
        []
      end

      # Returns Employee Relation Code
      def erc_code
        warn "DEPRECATED: erc_code is no longer supported"
        []
      end

      def represented?
        warn "DEPRECATED: represented? is no longer supported"
        []
      end

      def title_code
        warn "DEPRECATED: title_code is no longer supported"
        []
      end

      def appointment_type
        warn "DEPRECATED: appointment_type is no longer supported"
        []
      end

      # Returns +true+ if appointment is Without Salary
      def wos?
        warn "DEPRECATED: wos? is no longer supported"
        []
      end


      # Returns an Array of JobAppointment for <tt>uid</tt>, sorted by
      # record_number().
      # Returns an empty Array ([]) if nothing is found.
      #
      def self.find_by_uid(uid)
        warn "DEPRECATED: LDAP no longer provides job appointment data. This method will always return an empty array"
        []
      end

    end
  end
end
