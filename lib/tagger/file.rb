module Tagger
  class File

    def initialize(locale, instance)
      @locale = locale

      if Tagger.instances[instance.to_s].present?
        @instance = Tagger.instances[instance.to_s]
      else
        raise Tagger::NoInstanceConfiguredError.new("No instance configured with name : #{instance}")
      end
    end

    attr_reader :instance

    # range = 2-4
    def delta(range)
      
    end

    def tag
      create_tag_point if tagable?
    end

   # t1.<hexdigest>.en.json
    def tags
      File.join(instance.file_directory_path, 'tags')
    end

    private

    def range(range)
      range.split('-')
    end

    def create_tag_point
      tag_file_name = "#{tag_name}.#{current_hexdigest}.#{@locale}.#{instance.file_type}"
      FileUtils.cp(current_file_path, File.join(instance.file_directory_path, 'tags', tag_file_name))
      true
    end

    def tagable?
      available_hexdigests.exclude?(current_hexdigest)
    end

    def current_hexdigest
      hexdigest(current_file_path)
    end

    def current_file_path
      Dir[File.join(instance.file_directory_path, "root.#{@locale}.*")].last
    end

    # t1.<hexdigest>.en.json
    def available_hexdigests
      tags_directory = File.join(instance.file_directory_path, 'tags')
      Dir[tags_directory].map do |tag_file_path|
        tag_file_path.remove(tags_directory).split('.').second
      end
    end

    def hexdigest(file_path)
      Digest::SHA1.new.file(file_path).hexdigest
    end

  end
end

