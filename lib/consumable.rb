module Consumable

  extend ActiveSupport::Concern

  module ClassMethods

    def cleanup(max_lifetime, max_unconsumed_lifetime)
      transaction do
        conditions = ["created_on < ? OR (consumed IS NULL AND created_on < ?)",
                      Time.now - max_lifetime,
                      Time.now - max_unconsumed_lifetime]

        expired_tickets_count = count(:conditions => conditions)
        destroy_all(conditions)
      end
    end

  end

  module InstanceMethods

    def consume!
      self.consumed = Time.now
      self.save!
    end

  end

end
