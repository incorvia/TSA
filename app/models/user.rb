class User < ActiveRecord::Base
  has_secure_password

  attr_accessible :email, :encrypted_password

  class << self
    def validate(username, password)
      self.find_by_username(username).try(:authenticate, password)
    end
  end
end
