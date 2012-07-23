module Tickets
  class ProxyGrantingTicket < Ticket
    set_table_name 'proxy_granting_ticket'

    include Utilities

    belongs_to :granted_by_pgt,
      :class_name => 'Tickets::ProxyGrantingTicket',
      :foreign_key => :granted_by_pgt_id

    class << self

      def generate(env, pgt_url, attributes)
        uri = URI.parse(pgt_url)
        https = Net::HTTP.new(uri.host,uri.port)
        https.use_ssl = true

        # Here's what's going on here:
        #
        #   1. We generate a ProxyGrantingTicket (but don't store it in the database just yet)
        #   2. Deposit the PGT and it's associated IOU at the proxy callback URL.
        #   3. If the proxy callback URL responds with HTTP code 200, store the PGT and return it;
        #      otherwise don't save it and return nothing.
        #
        https.start do |conn|
          path = uri.path.empty? ? '/' : uri.path
          path += '?' + uri.query unless (uri.query.nil? || uri.query.empty?)

          attrs = {
            ticket: self.name + self.random_string(60),
            iou: self.name + ":IOU" + self.random_string(57),
            client_hostname: env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_HOST'] || env['REMOTE_ADDR']
          }
          attrs.reverse_merge!(attributes)

          pgt = ProxyGrantingTicket.new(attrs)

          path += (uri.query.nil? || uri.query.empty? ? '?' : '&') + "pgtId=#{pgt.ticket}&pgtIou=#{pgt.iou}"

          response = conn.request_get(path)

          if %w(200 202 301 302 304).include?(response.code)
            pgt.save!
            pgt
          else
            nil
          end

        end

      end

      def validate(ticket)
        if ticket.nil?
          raise ::TSA::ParameterMissing
        end

        pgt = ProxyGrantingTicket.find_by_ticket(ticket)

        if !pgt.service_ticket
          raise ::TSA::InvalidServiceAssociation
        end

        return pgt
      end

    end

  end

end

