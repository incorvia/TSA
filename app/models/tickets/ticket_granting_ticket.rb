module Tickets
  class TicketGrantingTicket < Ticket
    set_table_name 'ticket_granting_ticket'

    include Utilities

    has_many :granted_service_tickets,
      :class_name => 'Tickets::ServiceTicket',
      :foreign_key => :granted_by_tgt_id

    attr_accessible :ticket, :client_hostname, :username

    class << self

      def validate(ticket)
        max_session = configatron.maximum_session_lifetime

        tgt = Tickets::TicketGrantingTicket.find_by_ticket(ticket)

        if max_session && Time.now - tgt.created_on > max_session
          tgt.destroy
          raise ::TSA::SessionExpired
        end

        return tgt
      end

    end

  end

end

