module Tagger
  class Localizer
    # Add source directory path where your locales files are located
    SOURCE_DIRECTORY_PATH = Rails.root.join('app/assets/javascripts/dashboard-v2/locale/')

    # For Reseller Dashboard
    # SOURCE_DIRECTORY_PATH = Rails.root.join('app/assets/javascripts/reseller-dashboard/locale/')

    # For Server Side Dashboard
    # SOURCE_DIRECTORY_PATH = Rails.root.join('config/locales/')

    FILE_FORMAT = :json # (:json, :yml)

    # keep_recent_releases_count - will keep 3 recent releases of each locale root file
    # in /releases/ directory relative to specified source_directory_path.
    KEEP_RECENT_RELEASES_COUNT = 3

    # once you update files by rake, all invalid unnecessary files in source_directory_path will be deleted.
    # If you wants to prevent files from source dir, add name of file in ignore_source_directory_files array
    # Ex config.ignore_source_directory_files = %w(time-ago)
    IGNORE_SOURCE_DIRECTORY_FILES = %w(time-ago)

    # Locale::FrontendLocalizer.new(:en).update_files
    def initialize(locale)
      if I18n.available_locales.include?(locale.to_sym)
        @locale = locale
        @word_counter = Locale::WordCounter.new
        @current_file_version = fetch_current_file_version
        @current_file_path = current_locale_file_path
      else
        raise I18n::InvalidLocale.new(locale)
      end
    end

    attr_reader :current_file_version

    def extract
      keys_and_values = {}
      en_keys_and_values = load_full_keys_and_values(current_locale_file_path('en'))
      locale_keys_and_values = load_full_keys_and_values(current_locale_file_path)

      puts "Updating.."
      en_keys_and_values.each do |full_key, value|
        if locale_keys_and_values[full_key].nil? || locale_keys_and_values[full_key] == value
          keys_and_values[full_key] = value
        end
      end

      keys_and_values_to_file(keys_and_values, File.join(SOURCE_DIRECTORY_PATH, "delta.#{@locale}.#{FILE_FORMAT}"))
      puts 'Done.'
    end

    def update_files
      # 1) Get file contents as full keys and values
      keys_and_values = load_full_keys_and_values(current_locale_file_path)

      # 2) clone current keys and values for recent version entry
      old_version_keys_and_values = keys_and_values.clone

      # 3) Update existing key values with new file values
      puts "Updating.."

      new_file_phrases.each do |full_key, value|
        print "."
        @word_counter.update(keys_and_values[full_key], value)

        keys_and_values[full_key] = value
      end

      # 4) Migrate to new version if word changed detected
      if @word_counter.has_change?
        # Create last version file entry in releases
        create_recent_version_entry_for(old_version_keys_and_values)
        # Update root file to new version
        update_as_next_root_version(keys_and_values)
      end

      display_word_count
    end

    def full_keys_and_values
      load_full_keys_and_values(current_locale_file_path)
    end

    private

    def new_file_phrases
      keys_hash = {}

      other_locale_files_belongs_to_current_locale.each do |file_path|
        keys_hash.merge!(load_full_keys_and_values(file_path))
      end

      keys_hash
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

    def keys_and_values_to_file(keys_and_values, to_file_path)
      result = {}
      keys_and_values.each do |dot_key, value|
        h = result

        keys = if FILE_FORMAT == :yml then
          [@locale.to_s] + dot_key.split(".")
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

      final = if FILE_FORMAT == :json
        JSON.pretty_generate(result)
      elsif FILE_FORMAT == :yml
        YAML.dump(result)
      end

      File.open(to_file_path, "wb+") do |file|
        file.write(final)
      end
    end

    def other_locale_files_belongs_to_current_locale
      blacklisted_file_paths = IGNORE_SOURCE_DIRECTORY_FILES.map do |file_name|
        File.join(SOURCE_DIRECTORY_PATH, "#{file_name}.#{@locale}.#{FILE_FORMAT}")
      end

      Dir[File.join(SOURCE_DIRECTORY_PATH, "*.#{@locale}.#{FILE_FORMAT}")] - [blacklisted_file_paths, current_locale_file_path].flatten
    end

    def remove_invalid_files
      FileUtils.rm_f(@current_file_path)

      # Check for invalid files
      invalid_files = other_locale_files_belongs_to_current_locale

      # Remove old release file for current locale
      invalid_files << (current_locale_releases - current_locale_releases.sort.last(KEEP_RECENT_RELEASES_COUNT))

      invalid_files.flatten.each do |file_path|
        FileUtils.rm_f(file_path)
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
      Dir[File.join(SOURCE_DIRECTORY_PATH, 'releases', "*.#{@locale}.#{FILE_FORMAT}")]
    end

    def next_root_version_path
      # <latest_version>.root.fr.json
      File.join(SOURCE_DIRECTORY_PATH, "v#{next_file_version}.root.#{@locale}.#{FILE_FORMAT}")
    end

    def recent_version_path
      #<previous_version>.<Current Time stamp>.root.fr.json
      File.join(SOURCE_DIRECTORY_PATH, "releases", "#{current_file_version}.#{Time.now.strftime("%Y_%m_%d_T_%H_%M_%S")}.#{@locale}.#{FILE_FORMAT}")
    end

    def next_file_version
      current_file_version.sub('v', '').to_i + 1
    end

    def fetch_current_file_version
      current_locale_file_path.sub(SOURCE_DIRECTORY_PATH.to_s, '').scan(/v[0-9]*/).first || 'v1'
    end

    def load_full_keys_and_values(file_path)
      json = {}
      keys_and_values = {}

      begin
        json = if FILE_FORMAT == :json
          JSON.parse(File.read(file_path))
        elsif FILE_FORMAT == :yml
          YAML.load_file(file_path)
        end

      rescue Exception => e
        puts "\e[31mFailed to parse #{FILE_FORMAT} file #{file_path}, Please ensure before merge \e[0m"
      end

      traverse(json) do |keys, value|
        keys = keys.map{|m| m.split('.')}.flatten

        _keys = (FILE_FORMAT == :yml ? keys[1..-1] : keys)
        keys_and_values[_keys * '.'] = value
      end

      keys_and_values
    end

    def current_locale_file_path(locale = nil)
      Dir[File.join(SOURCE_DIRECTORY_PATH, "*root.#{locale || @locale}.#{FILE_FORMAT}")].last
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

    # def blacklisted_phrases_keys
    #   IGNORE_SOURCE_DIRECTORY_FILES.map do |file_name|
    #     load_locale_file(File.join(SOURCE_DIRECTORY_PATH, "#{file_name}.#{@locale}.#{FILE_FORMAT}")).keys
    #   end.flatten
    # end
  end
end
