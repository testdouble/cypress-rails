require "pathname"

module CypressRails
  class FindsBin
    LOCAL_PATH = "node_modules/.bin/cypress"

    def call(cy_dir = Dir.pwd)
      local_path = Pathname.new(cy_dir).join(LOCAL_PATH)
      if File.exist?(local_path)
        local_path
      else
        "cypress"
      end
    end
  end
end
