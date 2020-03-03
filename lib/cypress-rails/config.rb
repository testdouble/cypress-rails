require_relative "env"

module CypressRails
  class Config < Struct.new(:dir, :port, :transactional_server, :cypress_cli_opts, keyword_init: true)
    def initialize(
      dir: Env.fetch("CYPRESS_RAILS_DIR", default: Dir.pwd),
      port: Env.fetch("CYPRESS_RAILS_PORT"),
      transactional_server: Env.fetch("CYPRESS_RAILS_TRANSACTIONAL_SERVER", type: :boolean, default: true),
      cypress_cli_opts: Env.fetch("CYPRESS_RAILS_CYPRESS_OPTS", default: "")
    )
      super
    end

    def to_s
      <<~DESC

        cypress-rails configuration:
        ============================
         CYPRESS_RAILS_DIR.....................#{dir.inspect}
         CYPRESS_RAILS_PORT....................#{port.inspect}
         CYPRESS_RAILS_TRANSACTIONAL_SERVER....#{transactional_server.inspect}
         CYPRESS_RAILS_CYPRESS_OPTS............#{cypress_cli_opts.inspect}

      DESC
    end
  end
end
