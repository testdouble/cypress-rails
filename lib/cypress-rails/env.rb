module CypressRails
  module Env
    def self.fetch(name, type: :string, default: nil)
      return default unless ENV.key?(name)

      if type == :boolean
        if ["", "0", "n", "no", "false"].include?(ENV.fetch(name))
          false
        else
          true
        end
      else
        ENV.fetch(name)
      end
    end
  end
end
