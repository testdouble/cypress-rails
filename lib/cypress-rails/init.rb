module CypressRails
  class Init
    CONFIG_EXTENSIONS = %w[js ts mjs cjs mts cts]

    DEFAULT_CONFIG = <<~JS
      const { defineConfig } = require('cypress')

      module.exports = defineConfig({
        // setupNodeEvents can be defined in either
        // the e2e or component configuration
        e2e: {
          setupNodeEvents(on, config) {
            on('before:browser:launch', (browser = {}, launchOptions) => {
              /* ... */
            })
          },
        },
        screenshotsFolder: "tmp/cypress_screenshots",
        videosFolder: "tmp/cypress_videos",
        trashAssetsBeforeRuns: false
      })
    JS

    def call(cypress_dir = Config.new.cypress_dir)
      existing_config_path = Dir.glob(File.join(cypress_dir, "cypress.config.{#{CONFIG_EXTENSIONS.join(",")}}")).first
      if existing_config_path
        warn "Cypress config already exists in `#{existing_config_path}'. Skipping."
      else
        config_path = File.join(cypress_dir, "cypress.config.js")
        File.write(config_path, DEFAULT_CONFIG)
        puts "Cypress config initialized in `#{config_path}'"
      end
    end
  end
end
