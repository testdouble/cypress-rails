const { defineConfig } = require('cypress')
const replay = require('@replayio/cypress')

module.exports = defineConfig({
  // setupNodeEvents can be defined in either
  // the e2e or component configuration
  e2e: {
    setupNodeEvents(on, config) {
      replay.default(on, config)
      return config
      // on('before:browser:launch', (browser = {}, launchOptions) => {
      // })
    },
  },
  screenshotsFolder: "tmp/cypress_screenshots",
  videosFolder: "tmp/cypress_videos",
  trashAssetsBeforeRuns: false
})
