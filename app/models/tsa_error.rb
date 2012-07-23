module TSA

  class Error
    attr_accessor :message, :code

    def initialize(msg, code)
      @message = msg
      @code = code
    end
  end

  class InvalidTicket < TSA::Error
    def initialize(msg = "Invalid Ticket", code=400)
      super(msg, code)
    end
  end

  class ConsumedTicket < TSA::Error
    def initialize(msg = "Ticket has already been consumed", code=400)
      super(msg, code)
    end
  end

  class ExpiredTicket < TSA::Error
    def initialize(msg = "Ticket has expired", code=400)
      super(msg, code)
    end
  end

  class TicketConsumed < TSA::Error
    def initialize(msg = "Ticket has been consumed", code=400)
      super(msg, code)
    end
  end

  class SessionExpired < TSA::Error
    def initialize(msg = "Session has expired", code=400)
      super(msg, code)
    end
  end

  class ParameterMissing < TSA::Error
    def initialize(msg = "A parameter need to fulfill this request is missing", code=400)
      super(msg, code)
    end
  end

  class InvalidService < TSA::Error
    def initialize(msg = "Invalid service", code=400)
      super(msg, code)
    end
  end

  class InvalidProxyAssociation < TSA::Error
    def initialize(msg = "Proxy ticket is not associated with a proxy", code=400)
     super(msg, code)
    end
  end

  class InvalidServiceAssociation < TSA::Error
    def initialize(msg = "Proxy ticket is not associated with a service ticket", code=400)
     super(msg, code)
    end
  end

  class RedirectionLoop < TSA::Error
    def initialize(msg = "Redirection Loop Intercepted", code=400)
     super(msg, code)
    end
  end

  class GatewayNoService < TSA::Error
    def initialize(msg = "Gateway request but no service parameter given", code=400)
     super(msg, code)
    end
  end

  class InvalidURI < TSA::Error
    def initialize(msg = "The service is not a valid URI", code=400)
     super(msg, code)
    end
  end

end
