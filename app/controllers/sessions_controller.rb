class SessionsController < ApplicationController
  before_filter :set_default_response_headers, only: [:new]

  def new
    @renew = params['renew']
    @gateway = params['gateway'] == 'true' || params['gateway'] == '1'
    @service = clean_service_url(params['service'])

    if tgc = session['tgt']
      tgt = Tickets::TicketGrantingTicket.validate(tgc)
    end

    if params['redirection_loop_intercepted']
      error = ::TSA::RedirectionLoop.new
    end

    if @service
      if @renew
        to_login = true
      elsif tgt
        attrs = {service: @service, username: tgt.username, granted_by_tgt_id: tgt.id}
        st = Tickets::ServiceTicket.generate(env, attrs)
        service_with_ticket = st.uri_with_ticket
        redirect_to service_with_ticket, status: 303 # response code 303 means "See Other" (see Appendix B in CAS Protocol spec)
      elsif @gateway
        redirect_to @service, status: 303
      else
        to_login = true
      end
    elsif @gateway
      raise ::TSA::GatewayNoService
    end

    if to_login
      lt = Tickets::LoginTicket.generate(env)
      @lt = lt.ticket
    end
  end

  def create
    @service = clean_service_url(params['service'])
    @lt = params['lt']

    if error = Tickets::LoginTicket.validate(@lt)
      error = ::TSA::InvalidTicket.new
      @lt = Tickets::LoginTicket.generate(env)
      return render 'new', status: 500
    end

    user = User.validate(params['username'].downcase, params['password'])

    if user
      attrs = {username: user.username}
      tgt = Tickets::TicketGrantingTicket.generate(env, attrs)
      session['tgt'] = tgt.to_s

      if @service.blank?
        flash[:notice] = "Successfully authenticated but no service was given so we will not redirect."
        redirect_to '/login'
      else
        attrs = {service: @service, username: tgt.username, granted_by_tgt_id: tgt.id}
        st = Tickets::ServiceTicket.generate(env, attrs)
        service_with_ticket = st.uri_with_ticket
        redirect_to service_with_ticket, status: 303 # response code 303 means "See Other" (see Appendix B in CAS Protocol spec)
      end
    else
      flash[:notice] = "Invalid credentials, please try again"
      redirect_to request.referrer
    end
  end

  def destroy
    @service = clean_service_url(params['service'] || params['destination'])
    @gateway = params['gateway'] == 'true' || params['gateway'] == '1'

    tgt = Tickets::TicketGrantingTicket.find_by_ticket(session['tgt'])

    reset_session

    if tgt
      Tickets::TicketGrantingTicket.transaction do
        tgt.granted_service_tickets.each do |st|
          st.destroy
        end

        pgts = Tickets::ProxyGrantingTicket.includes(:service_ticket).where('service_ticket.username' => tgt.username)
        pgts.each do |pgt|
          pgt.destroy
        end

        tgt.destroy
      end
    end

    @message = {:type => 'confirmation', :message => "You have successfully logged out"}

    @lt = Tickets::LoginTicket.generate(env)

    if @gateway && @service
      redirect_to @service, status: 303
    else
      redirect_to 'login'
    end
  end

  def proxy_validate
    @service = clean_service_url(params['service'])
    @ticket = params['ticket']
    @pgt_url = params['pgtUrl']
    @renew = params['renew']
    @proxies = []

    ticket, error = Tickets::ProxyTicket.validate(@service, @ticket)

    @success = t && !error

    if @success
      @username = ticket.username

      if t.kind_of? Tickets::ProxyTicket
        @proxies << ticket.granted_by_pgt.service_ticket.service
      end

      if @pgt_url
        attrs = {
          service_ticket_id: ticket.id, 
          iou: "PGTIOU-" + Tickets::ProxyGrantingTicket.random_string(60),
          ticket: "Tickets::ProxyGrantingTicket" + Tickets::ProxyGrantingTicket.random_string(57)
        }
        pgt = Tickets::ProxyGrantingTicket.generate(env, attrs)
        @pgtiou = pgt.iou
      end
    end

    @error = error
    render :proxy_validate
  end

  def set_default_response_headers
    headers['Pragma'] = 'no-cache'
    headers['Cache-Control'] = 'no-store'
    headers['Expires'] = (Time.now - 1.year).rfc2822
  end

  def clean_service_url(dirty)
    return dirty if dirty.blank?

    clean_service = dirty.dup
    ['service', 'ticket', 'gateway', 'renew'].each do |p|
      clean_service.sub!(Regexp.new("&?#{p}=[^&]*"), '')
    end

    clean_service.gsub!(/[\/\?&]$/, '') # remove trailing ?, /, or &
    clean_service.gsub!('?&', '?')
    clean_service.gsub!(' ', '+')

    return clean_service

  end
end
