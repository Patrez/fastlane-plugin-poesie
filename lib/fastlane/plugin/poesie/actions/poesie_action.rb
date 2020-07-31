require 'poesie'

module Fastlane
  module Actions
    class PoesieAction < Action
      def self.run(params)
        exporter = ::Poesie::Exporter.new(params[:api_token], params[:project_id])
        languages = params[:languages]
        if languages.nil?
          languages = Helper::PoesieHelper.list_of_languages(params[:api_token], params[:project_id])
        end

        paths = Helper::PoesieHelper.path_for_localized_file(languages, params[:strings_file_name], params[:strings_path])

        if paths.count != languages.count
          ::Poesie.exit_with_error("Error while finding localized files.\nSearching for languages: #{languages}\nFound: #{paths.keys
            }}")
        end

        languages.each do |language|
          ::Poesie::Log::title("== Language #{language} ==")
          string_path = paths[language]
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
        ["Patrik Potoček", "Adam Bezák"]
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
            optional: true,
            type: Array),
          FastlaneCore::ConfigItem.new(key: :strings_file_name,
            env_name: "PROJECT_STRING_FILE_NAME",
            description: "Name of a localized .strings file. Default is Localizable.strings",
            optional: true,
            type: String),
          FastlaneCore::ConfigItem.new(key: :strings_path,
            env_name: "PROJECT_STRING_PATH",
            description: "Path to a directory where poesie will search for .string files",
            optional: true,
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
