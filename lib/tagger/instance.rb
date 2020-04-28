module Tagger
	class Instance
		def initialize(config, name)
			@file_directory_path = config.file_directory_path
			@keep_recent_tags = config.keep_recent_tags
			@file_type = config.file_type
			@name = name
		end

		attr_reader :file_directory_path, :keep_recent_tags, :file_type, :name

		def tags_directory
			::File.join(file_directory_path, 'tags')
		end

		def locales
			available_locale_codes.map do |locale|
				Tagger::Locale.new(self, locale)
			end	
		end

		def available_locale_codes
			Dir[::File.join(file_directory_path.to_s, "*root.*")].map do |m| 
				m.sub(file_directory_path.to_s, '').split(".").second_to_last
			end
		end
	end
end