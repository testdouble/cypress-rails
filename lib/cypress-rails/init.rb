module CypressRails
  class Init
    DEFAULT_CONFIG = <<~CYPRESS_CONFIG
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

    CYPRESS_CONFIG

    def call(dir = Dir.pwd)
      config_path = File.join(dir, "cypress.config.js")
      if File.exist?(config_path)
        warn('Cypress config is already exist!')
        return
      end
      File.write(config_path, DEFAULT_CONFIG)
      puts "Cypress config initialized in #{config_path}"
    end
  end
end
