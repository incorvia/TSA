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
        else Time.now - login_ticket.created_on > settings.config[:maximum_unused_login_ticket_lifetime]
          error =  ::TSA::ExpiredLoginTicket.new
        end

        login_ticket.consume!
      end
    end
  end
end
