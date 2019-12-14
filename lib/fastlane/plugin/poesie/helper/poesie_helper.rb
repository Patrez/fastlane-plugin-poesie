require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class PoesieHelper
      # class methods that you define here become available in your action
      # as `Helper::PoesieHelper.your_method`
      #
      def self.list_of_languages(api_token, project_id)
        uri = URI('https://api.poeditor.com/v2/languages/list')
        res = Net::HTTP.post_form(uri, 'api_token' => api_token, 'id' => project_id, 'type' => 'json')
        json = JSON.parse(res.body)
        unless json['response']['status'] == 'success'
          r = json['response']
          puts "Error #{r['code']} (#{r['status']})\n#{r['message']}"
          exit 1
        end
        json["result"]["languages"].map { |lan| lan["code"] }
      end

      def self.path_for_localized_file(languages, filename = nil)
        require 'find'

        if filename.nil?
          filename = "Localizable.strings"
        end
        paths = {}
        Find.find(Dir.pwd) do |path|
          if FileTest.file?(path) && File.basename(path) == filename
            languages.each { |lang|
              if File.basename(File.dirname(path)) == "#{lang}.lproj"
                paths[lang] = path
              end
            }
            Find.prune
          else
            next
          end
        end
        paths
      end
    end
  end
end
