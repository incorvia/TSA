module Tickets
  class ProxyTicket < ServiceTicket
    belongs_to :granted_by_pgt,
      :class_name => 'Tickets::ProxyGrantingTicket',
      :foreign_key => :granted_by_pgt_id

    class << self

      def validate(service, ticket)
        pt, error = Tickets::ServiceTicket.validate(service, ticket, true)

        if pt.kind_of?(Tickets::ProxyTicket)
          if !pt.granted_by_pgt
            error = ::TSA::InvalidProxyAssociation.new
          elsif !pt.granted_by_pgt.service_ticket
            error =  ::TSA::InvalidServiceAssociation.new
          end
        end

        [pt, error]
      end

    end

  end

end


