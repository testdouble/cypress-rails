require_relative "config"
require_relative "initializer_hooks"

module CypressRails
  class ResetsState
    def initialize
      @initializer_hooks = InitializerHooks.instance
    end

    def call
      @initializer_hooks.run(:after_reset_requested)
    end
  end
end
