class TaggerGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)

  def create_initializer_file
    initializer_location = "config/initializers/tagger.rb"
    copy_file initializer_location, initializer_location
  end

  # def create_migrations
  #   create_taggger_users = "db/migrate/create_tagger_users.rb"
  #   migration_template create_taggger_users, create_taggger_users
  # end

  def self.next_migration_number(path)
    sleep 1 # migration numbers should differentiate
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def migration_version
    "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if rails_major_version >= 5
  end

  def rails_major_version
    Rails.version.first.to_i
  end

end


