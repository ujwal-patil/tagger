module Tagger
	class Locale
		def initialize(locale_code, instance)
			@code = locale_code

      if instance.is_a?(Tagger::Instance)
      	@instance = instance
      else
				@instance = Tagger::Instance.new(Tagger.class_variable_get("@@#{instance}"), instance)
      end
		end

		attr_reader :code, :instance

		CURRENT_TAG_NO = -9999999999

		 # t1.<hexdigest>.en.json
    def tags
      _tags = available_tag_files.map do |file_path|
  			if file_path.present?
  				file_name = file_path.remove("#{instance.tags_directory}/")
  				_name = file_name.split('.')

			    OpenStruct.new({
			    	file_path: file_path,
		      	original: file_name,
		      	name: _name.first,
		      	created_at: _name.second.to_i,
		      	negative: (- _name.second.to_i),
		      	hexdigest: _name.third,
		      	locale: _name.second_to_last
		      })
  			end
  		end.compact

  		_tags.sort_by{|tag| tag.created_at}
    end

    def available_tag_files
      tags_directory = ::File.join(instance.tags_directory, "*.#{code}.#{instance.file_type}")

      Dir[tags_directory]
    end
  
    def delta(tag_id)
      Tagger::Localizer.new(self).delta(tag_id)
    end

    def upload(file)
    	Tagger::Localizer.new(self).upload(file)
    end

    def tag
      create_tag_point if tagable?
    end

    def current_file_path
      Dir[::File.join(instance.file_directory_path, "*root.#{code}.#{instance.file_type}")].last
    end

    private

    def create_tag_point
      tag_file_name = "#{tag_name}.#{Time.now.to_i}.#{current_hexdigest}.#{code}.#{instance.file_type}"
      FileUtils.cp(current_file_path, ::File.join(instance.file_directory_path, 'tags', tag_file_name))
      true
    end

    def tagable?
      available_hexdigests.exclude?(current_hexdigest)
    end

    def tag_name
      Time.now.strftime("%^b%d")
    end

    def current_hexdigest
      hexdigest(current_file_path)
    end

    # t1.<hexdigest>.en.json
    def available_hexdigests
      tags_directory = ::File.join(instance.tags_directory, "*.#{code}.#{instance.file_type}")
      Dir[tags_directory].map do |tag_file_path|
        tag_file_path.remove(instance.tags_directory).split('.').third
      end
    end

    def hexdigest(file_path)
      Digest::SHA1.new.file(file_path).hexdigest
    end
	end
end