class Ticket < ActiveRecord::Base
  self.abstract_class = true

  attr_accessible :client_hostname, :ticket

  class << self

    def generate(env, attributes={})
      attrs = {
        ticket: self.name + self.random_string,
        client_hostname: env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_HOST'] || env['REMOTE_ADDR'],
      }
      attrs.reverse_merge!(attributes)
      attrs.reverse_merge!(type: self.name) if self.name == "Tickets::ServiceTicket"

      ticket = self.new(attrs)
      ticket.save!
      ticket
    end

    def cleanup(max_lifetime)
      transaction do
        conditions = ["created_on < ?", Time.now - max_lifetime]
        destroy_all(conditions)
      end
    end

  end

  def to_s
    ticket
  end

end
