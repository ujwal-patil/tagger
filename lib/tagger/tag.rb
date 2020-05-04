module Tagger
	class Tag
		def initialize(file_path, instance)
			@instance = instance
			file_name = file_path.remove("#{instance.tags_directory}/")
			_name = file_name.split('.')

    	@file_path = file_path,
    	@original = file_name,
    	@name = _name.first,
    	@created_at = _name.second.to_i,
    	@hexdigest = _name.third,
    	@locale = _name.second_to_last
    	@file_type = _name.last
		end
		
		attr_reader :file_path, :instance, :original, :name, :created_at, :hexdigest, :locale, :file_type

		def remove
			FileUtils.rm_f(file_path)
		end
	end
end