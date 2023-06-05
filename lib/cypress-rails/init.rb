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
      config_content = determine_new_config(config_path)
      File.write(config_path, config_content)
      puts "Cypress config (re)initialized in #{config_path}"
    end

    private

    def determine_new_config(config_path)
      if File.exist?(config_path)
        merge_existing_with_defaults(config_path) 
      else
        DEFAULT_CONFIG
      end
    end

    def merge_existing_with_defaults(config_path)
      File.read(config_path)
    end
  end
end
