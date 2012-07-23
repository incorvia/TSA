module Utilities

  extend ActiveSupport::Concern

  module ClassMethods

    def random_string(max_length = 29)
      crypt =  Crypt::ISAAC.new
      max = 4294619050
      r = "#{Time.now.to_i}r%X%X%X%X%X%X%X%X" %
        [crypt.rand(max), crypt.rand(max), crypt.rand(max), crypt.rand(max),
         crypt.rand(max), crypt.rand(max), crypt.rand(max), crypt.rand(max)]
      r[0..max_length-1]
    end

  end

end
