module CypressRails
  class Init
    DEFAULT_CONFIG = {
      "screenshotsFolder" => "tmp/cypress_screenshots",
      "videosFolder" => "tmp/cypress_videos",
      "trashAssetsBeforeRuns" => false
    }

    def call(dir = Dir.pwd)
      config_path = File.join(dir, "cypress.json")
      json = JSON.pretty_generate(determine_new_config(config_path))
      File.write(config_path, json)
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

    def merge_existing_with_defaults(json_path)
      existing = JSON.parse(File.read(json_path))
      base_url = existing["baseUrl"]
      if base_url
        base_uri = URI(base_url)
        has_path = base_uri.path != "" && base_uri.path != "/"
        not_using_http = base_uri.scheme != "http"

        if has_path || not_using_http
          path_message = if has_path
                           "contains a path ('#{base_uri.path}')"
                         else
                           nil
                         end
          scheme_message = if not_using_http
                             "not using http:// (using '#{base_uri.scheme}')"
                           else
                             nil
                           end
          raise "Your baseUrl '#{base_url}' is not supported: it #{[path_message,scheme_message].join('.')}.  You will need to modify your baseUrl to 'http://#{base_uri.host}:#{base_uri.port}' and modify your Cypress tests to assume this baseUrl"
        end
      end
      Hash[existing.merge(DEFAULT_CONFIG).sort]
    end
  end
end
