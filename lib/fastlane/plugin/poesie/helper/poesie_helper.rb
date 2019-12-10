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

      def test
        puts "wtf"
      end
    end
  end
end
