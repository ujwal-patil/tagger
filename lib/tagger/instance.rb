module Tagger
	class Instance
		def initialize(config, name)
			@file_directory_path = config.file_directory_path
			@keep_recent_tags = config.keep_recent_tags
			@file_type = config.file_type

			if Tagger.configured_instances.include?(name.to_s)
				@name = name
				FileUtils::mkdir_p(::File.join(file_directory_path, 'tags'))
      else
        raise Tagger::NoInstanceConfiguredError.new("No instance configured with name : #{name}")
      end
		end

		attr_reader :file_directory_path, :keep_recent_tags, :file_type, :name

		def tags_directory
			::File.join(file_directory_path, 'tags')
		end

		def locales
			available_locale_codes.map do |locale|
				Tagger::Locale.new(locale, self) if locale != 'en'
			end.compact
		end

		def available_locale_codes
			Dir[::File.join(file_directory_path.to_s, "*root.*")].map do |m| 
				m.sub(file_directory_path.to_s, '').split(".").second_to_last
			end
		end
	end
end