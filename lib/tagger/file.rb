module Tagger
  class File

    def initialize(locale, instance_name)
      @locale = locale
      instance_name = instance_name.to_s
      if Tagger.instances.map(&:name).include?(instance_name)
        @instance = Tagger::Instance.new(Tagger.class_variable_get("@@#{instance_name}"), instance_name)
        FileUtils::mkdir_p(::File.join(instance.file_directory_path, 'tags'))
      else
        raise Tagger::NoInstanceConfiguredError.new("No instance configured with name : #{instance}")
      end
    end

    attr_reader :instance, :locale

    # range = 2-4
    def delta(range)
      
    end

    def tag
      create_tag_point if tagable?
    end

   # t1.<hexdigest>.en.json
    def tags
      ::File.join(instance.file_directory_path, 'tags')
    end

    def current_file_path
      Dir[::File.join(instance.file_directory_path, "root.#{locale}.*")].last
    end

    private

    def range(range)
      range.split('-')
    end

    def create_tag_point
      tag_file_name = "#{tag_name}.#{Time.now.to_i}.#{current_hexdigest}.#{locale}.#{instance.file_type}"
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
      tags_directory = ::File.join(instance.tags_directory, "*.#{locale}.#{instance.file_type}")
      Dir[tags_directory].map do |tag_file_path|
        tag_file_path.remove(instance.tags_directory).split('.').third
      end
    end

    def hexdigest(file_path)
      Digest::SHA1.new.file(file_path).hexdigest
    end

  end
end

