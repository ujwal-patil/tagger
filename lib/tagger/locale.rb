class Tagger::Locale
  def initialize(locale_code, instance)
    @code = locale_code

    if instance.is_a?(Tagger::Instance)
      @instance = instance
    else
      @instance = Tagger::Instance.new(Tagger.class_variable_get("@@#{instance}"), instance)
    end
  end

  attr_reader :code, :instance

  def tags
    _tags = available_tag_files.map do |file_path|
      Tagger::Tag.new(file_path, instance) if file_path.present?       
    end.compact.sort_by{|tag| tag.created_at}
  end

  def available_tag_files
    Dir[::File.join(instance.tags_directory, "*.#{code}.#{'json'}")]
  end
  
  def delta(tag_id)
    Tagger::Localizer.new(self).delta(tag_id)
  end

  def pending_status
    Tagger::Localizer.new(self).pending_status
  end

  def upload(file)
    Tagger::Localizer.new(self).upload(file)
  end

  def complete_json
    Tagger::Localizer.new(self).full_keys_and_values
  end

  def current_file_path
    Dir[::File.join(instance.file_directory_path, "*root.#{code}.#{instance.file_type}")].last
  end
end
