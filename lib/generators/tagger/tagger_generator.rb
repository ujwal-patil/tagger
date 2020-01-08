class TaggerGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def create_initializer_file
    initializer_location = "config/initializers/tagger.rb"
    copy_file initializer_location, initializer_location
  end
end