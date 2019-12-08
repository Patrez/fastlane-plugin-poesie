require 'fastlane/action'
require 'poesie'

module Fastlane
  module Actions
    class PoesieAction < Action
      def self.run(params)
        exporter = ::Poesie::Exporter.new(params[:api_token], params[:project_id])
        params[:languages].each do |language|
          ::Poesie::Log::title("== Language #{language} ==")
          string_path = params[:string_files_path] + language + ".lproj/Localizable.strings"
          exporter.run(language) do |terms|
            # Localizable.strings
            ::Poesie::AppleFormatter::write_strings_file(
              terms,
              string_path,
              substitutions: nil,
              print_date: nil
            )

            # Localizable.stringsdict
            strings_dict_path = string_path.gsub(/\.strings$/,'.stringsdict')
            ::Poesie::AppleFormatter::write_stringsdict_file(
              terms,
              strings_dict_path,
              substitutions: nil,
              print_date: nil
            )
          end
        end
      end

      def self.description
        "Exports translations from POEditor using poesie tool."
      end

      def self.authors
        ["Patrik Potoček"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
            env_name: "POEDITOR_API_TOKEN",
            description: "The API token for a POEditor.com Account",
            optional: false,
            type: String),
          FastlaneCore::ConfigItem.new(key: :project_id,
            env_name: "POEDITOR_PROJECT_ID",
            description: "The ID of the POEditor.com Project",
            optional: false,
            type: String),
          FastlaneCore::ConfigItem.new(key: :languages,
            env_name: "POEDITOR_SUPPORTED_LANGUAGES",
            description: "The languages to export",
            optional: false,
            type: Array),
          FastlaneCore::ConfigItem.new(key: :string_files_path,
            env_name: "PROJECT_STRING_FILES_PATH",
            description: "The path to localized string files",
            optional: false,
            type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        [:ios, :mac].include?(platform)
      end
    end
  end
end
