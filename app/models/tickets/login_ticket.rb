module Tickets
  class LoginTicket < Ticket
    set_table_name 'login_ticket'

    include Consumable
    include Utilities

    class << self

      def validate(ticket)
        login_ticket = LoginTicket.find_by_ticket(ticket)

        if login_ticket.consumed?
          error = ::TSA::ConsumedLoginTicket.new
        elsif Time.now - login_ticket.created_on > configatron.maximum_unused_login_ticket_lifetime
          error =  ::TSA::ExpiredTicket.new
        end

        login_ticket.consume!
        return error
      end
    end
  end
end
