module UCB
  module LDAP
    ##
    # Class for accessing the Namespace/Name part of LDAP.
    #
    class Namespace < Entry
      @tree_base = 'ou=names,ou=namespace,dc=berkeley,dc=edu'
      @entity_name = 'namespaceName'

      def name
        cn.first
      end

      ##
      # Returns +Array+ of services
      #
      def services
        berkeleyEduServices
      end

      def uid
        super.first
      end

      ##
      # Returns an +Array+ of Namespace for _uid_.
      #
      def self.find_by_uid(uid)
        warn "DEPRECATED: Namespaces are no longer supported by LDAP. This method always returns an empty Array"
        []
      end

      ##
      # Returns Namespace instance for _cn_.
      #
      def self.find_by_cn(cn)
        warn "DEPRECATED: Namespaces are no longer supported by LDAP. This method always returns an empty Array"
        []
      end
    end
  end
end
