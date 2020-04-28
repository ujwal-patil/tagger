module Tagger
	class Locale
		def initialize(instance, locale_code)
			@code = locale_code
			@instance = instance
		end

		attr_reader :code, :instance

		 # t1.<hexdigest>.en.json
    def tags
      available_tag_file_names.map do |file_name|
  			if file_name.present?
  				_name = file_name.split('.')
			    OpenStruct.new({
		      	original: file_name,
		      	name: _name.first,
		      	created_at: _name.second,
		      	hexdigest: _name.third,
		      	locale: _name.second_to_last
		      })
  			end
  		end.compact
    end

    def available_tag_file_names
      tags_directory = ::File.join(instance.tags_directory, "*.#{code}.#{instance.file_type}")

      Dir[tags_directory].map do |tag_file_path|
        tag_file_path.remove("#{instance.tags_directory}/")
      end
    end
	end
end