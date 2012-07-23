module Tickets
  class ServiceTicket < Ticket
    set_table_name 'service_ticket'

    include Consumable
    include Utilities

    attr_accessible :service, :username, :granted_by_tgt_id, :type

    belongs_to :granted_by_tgt,
      :class_name => 'Tickets::TicketGrantingTicket',
      :foreign_key => :granted_by_tgt_id

    class << self

      def validate(service, ticket, allow_proxy_tickets = false)
        if service.nil? || ticket.nil?
          error = ::TSA::ParameterMissing.new
        end

        service_ticket = Tickets::ServiceTicket.find_by_ticket(ticket)

        if service_ticket
          if service_ticket.consumed?
            error =  ::TSA::TicketConsumed.new
          elsif service_ticket.kind_of?(Tickets::ProxyTicket) && !allow_proxy_tickets
            error =  ::TSA::InvalidTicket.new
          elsif Time.now - service_ticket.created_on > configatron.maximum_unused_service_ticket_lifetime
            error =  ::TSA::ExpiredTicket.new
          elsif !service_ticket.matches_service? service
            error =  ::TSA::InvalidService.new
          end

          service_ticket.consume!
        else
          error = ::TSA::InvalidTicket.new
        end

        [service_ticket, error]
      end

    end

    def matches_service?(service_url)
      self.service == service_url
    end

    def uri_with_ticket
      # This will choke with a URI::InvalidURIError if service URI is not properly URI-escaped...
      # This exception is handled further upstream (i.e. in the controller).
      service_uri = URI.parse(self.service)

      if self.service.include? "?"
        if service_uri.query.empty?
          query_separator = ""
        else
          query_separator = "&"
        end
      else
        query_separator = "?"
      end

      service_with_ticket = self.service + query_separator + "ticket=" + self.ticket
    end

  end

end

