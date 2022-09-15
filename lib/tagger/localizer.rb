module Tagger
  class Localizer

    def initialize(locale)
      @locale = locale
      @instance = locale.instance
      @code = locale.code
      @word_counter = Tagger::WordCounter.new

      @track_file_paths = []
      @current_file_version = fetch_current_file_version
      @current_file_path = current_locale_file_path
    end

    attr_reader :current_file_version, :locale, :instance, :code, :track_file_paths

    def delta(tag_id)
      tag_point_keys_and_values = {}
      delta_point_keys_and_values = {}
      from_tag_keys_and_values = {}

      en_keys_and_values = load_full_keys_and_values(current_locale_file_path('en'))
      locale_keys_and_values = load_full_keys_and_values(current_locale_file_path)

      if tag_id && tag_id != 'TODAY'
        file_path = find_tag(tag_id).file_path
        from_tag_keys_and_values = load_full_keys_and_values(file_path)
      end

      en_keys_and_values.each do |full_key, value|
        if (locale_keys_and_values[full_key].nil? || comparable(locale_keys_and_values[full_key]) == comparable(value))
          tag_point_keys_and_values[full_key] = value

          unless from_tag_keys_and_values.has_key?(full_key)
            delta_point_keys_and_values[full_key] = value
          end
        end
      end

      if tag_id && tag_id != 'TODAY'
        if tagable?(tag_point_keys_and_values)
          create_tag_point(tag_point_keys_and_values)
        end

        delta_point_keys_and_values
      else
        if tagable?(tag_point_keys_and_values)
          create_tag_point(tag_point_keys_and_values)
        else
          tag_file_for(tag_point_keys_and_values)
        end
      end
    end

    def pending_status
      en_keys_and_values = load_full_keys_and_values(current_locale_file_path('en'))
      locale_keys_and_values = load_full_keys_and_values(current_locale_file_path)

      count = 0

      en_keys_and_values.each do |full_key, value|
        count += 1 if (locale_keys_and_values[full_key].nil? || comparable(locale_keys_and_values[full_key]) == comparable(value))
      end

      ((count.to_f / en_keys_and_values.keys.length.to_f) * 100).round(2)
    end

    def find_tag(tag_id)
      locale.tags.find{|tag| tag.hexdigest == tag_id}
    end

    def tag_file_for(keys_and_values)
      hex = hexdigest(keys_and_values)
      tags_directory = ::File.join(instance.tags_directory, "*.#{hex}.#{code}.#{instance.file_type}")
      Dir[tags_directory].first
    end

    def upload(file)
      if file.blank?
        raise Tagger::FileNotFoundError.new("File not found!")
      end

      # 1) Get file contents as full keys and values
      keys_and_values = load_full_keys_and_values(current_locale_file_path).compact

      # 2) clone current keys and values for recent version entry
      old_version_keys_and_values = keys_and_values.clone

      # 3) Update existing key values with new file values
      uploaded_file_key_values = load_full_keys_and_values(file.path)
      uploaded_file_key_values.each do |full_key, value|
        @word_counter.update(keys_and_values[full_key], value)

        keys_and_values[full_key] = value
      end

      # 4) Migrate to new version if word changed detected
      if @word_counter.has_change?
        # Create last version file entry in releases
        create_recent_version_entry_for(old_version_keys_and_values)
        # Update root file to new version
        update_as_next_root_version(keys_and_values)
        
        sync_files_to_git(@word_counter)
      end

      @word_counter
    end

    def full_keys_and_values
      load_full_keys_and_values(current_locale_file_path)
    end

    private

    def comparable(value)
      value.to_s.downcase.gsub( /\s+/, "")
    end

    def add_file_for_tracking(path)
      if path.present?
        track_file_paths << path
      end
    end

    def create_tag_point(keys_and_values)
      tag_file_name = "#{tag_name}.#{Time.now.to_i}.#{hexdigest(keys_and_values)}.#{code}.#{instance.file_type}"
      tag_file_name = ::File.join(instance.file_directory_path, 'tags', tag_file_name)
      keys_and_values_to_file(keys_and_values, tag_file_name, true)

      recent_tag_ids = locale.tags.last(instance.keep_recent_tags).map(&:hexdigest)
      locale.tags.each do |tag| 
        if recent_tag_ids.exclude?(tag.hexdigest)
          tag.remove
          add_file_for_tracking(tag.file_path)
        end
      end

      sync_files_to_git

      tag_file_name
    end

    def tagable?(keys_and_values)
      available_hexdigests.exclude?(hexdigest(keys_and_values))
    end

    def tag_name
      Time.now.strftime("%^b%d-%T")
    end

    # t1.<hexdigest>.en.json
    def available_hexdigests
      tags_directory = ::File.join(instance.tags_directory, "*.#{code}.#{instance.file_type}")
      Dir[tags_directory].map do |tag_file_path|
        tag_file_path.remove(instance.tags_directory).split('.').third
      end
    end

    def hexdigest(contents)
      Digest::SHA1.new.hexdigest(contents.to_s)
    end

    def update_as_next_root_version(keys_and_values)
      # create new file with next root file version
      keys_and_values_to_file(keys_and_values, next_root_version_path)
      # remove existing root file
      remove_invalid_files
    end

    def create_recent_version_entry_for(keys_and_values)
      keys_and_values_to_file(keys_and_values, recent_version_path)
    end

    def keys_and_values_to_file(keys_and_values, to_file_path, save_as_full_keys=false)
      result = {}
      if save_as_full_keys
        result = keys_and_values
      else
        keys_and_values.each do |dot_key, value|
          h = result

          keys = if instance.file_type == :yml then
            [code.to_s] + dot_key.split(".")
          else
            dot_key.split(".")
          end

          keys.each_with_index do |key, index|
            h[key] = {} unless h.has_key?(key)
            if index == keys.length - 1
              h[key] = value
            else
              h = h[key]
            end
          end
        end        
      end

      final = if instance.file_type == :json
        JSON.pretty_generate(result)
      elsif instance.file_type == :yml
        YAML.dump(result)
      end

      File.open(to_file_path, "wb+") do |file|
        file.write(final)
      end

      if File.exist?(to_file_path)
        add_file_for_tracking(to_file_path)
      end
    end

    def other_locale_files_belongs_to_current_locale
      blacklisted_file_paths = instance.ignore_source_directory_files.map do |file_name|
        File.join(instance.file_directory_path, "#{file_name}.#{code}.#{instance.file_type}")
      end

      Dir[File.join(instance.file_directory_path, "*.#{code}.#{instance.file_type}")] - [blacklisted_file_paths, current_locale_file_path].flatten
    end

    def remove_invalid_files
      FileUtils.rm_f(@current_file_path)

      add_file_for_tracking(@current_file_path)

      # Check for invalid files
      invalid_files = other_locale_files_belongs_to_current_locale

      # Remove old release file for current locale
      invalid_files << (current_locale_releases - current_locale_releases.sort.last(instance.keep_recent_releases))

      invalid_files.flatten.each do |file_path|
        FileUtils.rm_f(file_path)
        add_file_for_tracking(file_path)
        puts "\n\e[31mRemoved invalid file: #{file_path}\e[0m"
      end
    end

    def display_word_count
      puts "\n"
      puts <<-Translator
        ========================================================================
            Added Word Count : #{@word_counter.added_words}
          Removed Word Count : #{@word_counter.removed_words}
        ========================================================================
      Translator
    end

    def current_locale_releases
      Dir[File.join(instance.file_directory_path, 'releases', "*.#{code}.#{instance.file_type}")]
    end

    def next_root_version_path
      # <latest_version>.root.fr.json
      File.join(instance.file_directory_path, "v#{next_file_version}.root.#{code}.#{instance.file_type}")
    end

    def recent_version_path
      #<previous_version>.<Current Time stamp>.root.fr.json
      File.join(instance.file_directory_path, "releases", "#{current_file_version}.#{Time.now.strftime("%Y_%m_%d_T_%H_%M_%S")}.#{code}.#{instance.file_type}")
    end

    def next_file_version
      current_file_version.sub('v', '').to_i + 1
    end

    def fetch_current_file_version
      current_locale_file_path.sub(instance.file_directory_path.to_s, '').scan(/v[0-9]*/).first || 'v1'
    end

    def load_full_keys_and_values(file_path)
      json = {}
      keys_and_values = {}

      begin
        json = if instance.file_type == :json
          JSON.parse(File.read(file_path))
        elsif instance.file_type == :yml
          YAML.load_file(file_path)
        end

      rescue Exception => e
        puts "\e[31mFailed to parse #{instance.file_type} file #{file_path}, Please ensure before merge \e[0m"
      end

      traverse(json) do |keys, value|
        keys = keys.map{|m| m.split('.')}.flatten

        _keys = (instance.file_type == :yml ? keys[1..-1] : keys)
        keys_and_values[_keys * '.'] = value
      end

      keys_and_values.compact
    end

    def current_locale_file_path(_code = nil)
      Dir[File.join(instance.file_directory_path, "*root.#{_code || code}.#{instance.file_type}")].last
    end

    def traverse(obj, keys = [], &block)
      case obj
      when Hash
        obj.each do |k,v|
          keys << k
          traverse(v, keys, &block)
          keys.pop
        end
      when Array
        obj.each { |v| traverse(v, keys, &block) }
      else
        yield keys, obj
      end
    end

    def sync_files_to_git(word_counter=nil)
      _track_file_paths = track_file_paths.compact.uniq
      return if _track_file_paths.blank?

      params = {
        instance_name: instance.name,
        locale: locale.code
      }

      params[:track_file_paths] = _track_file_paths.map do |path|
        path.remove("#{::Rails.root}/")
      end

      if word_counter
        params[:added_words] = word_counter.added_words
        params[:removed_words] = word_counter.removed_words
      end

      # GitJob.perform_later(params)
    end

    # def blacklisted_phrases_keys
    #   instance.ignore_source_directory_files.map do |file_name|
    #     load_locale_file(File.join(instance.file_directory_path, "#{file_name}.#{code}.#{instance.file_type}")).keys
    #   end.flatten
    # end
  end
end
