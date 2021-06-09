require "pathname"
require_relative "config"

module CypressRails
  class FindsBin
    def call(dir = Dir.pwd, config = Config.new)
      local_path = config.cypress_path
      if File.exist?(local_path)
        # local_path = Pathname.new(dir).join(LOCAL_PATH)
        local_path
      else
        "cypress"
      end
    end
  end
end
