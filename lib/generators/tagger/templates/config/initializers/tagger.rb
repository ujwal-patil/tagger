Tagger.setup do |config|
  config.parent_controller = 'ApplicationController'

  config.instance(:instance_name) do |instance_name|
    # file_directory_path - Where your locale json files are located
    instance_name.file_directory_path = Rails.root.join('app/assets/javascripts/locale')

    # file type like json, yaml etc.
    instance_name.file_type = :json

    # keep_recent_tags - This will keep only 5 recent tag versions
    instance_name.keep_recent_tags = 5

    # keep_recent_releases - will keep 5 recent releases of each locale root file
    # in /releases/ directory relative to specified source_directory_path.
    instance_name.keep_recent_releases = 5

    # once you upload file, all invalid unnecessary files in source_directory_path will be deleted.
    # If you wants to prevent files from source dir, add name of file in ignore_source_directory_files array
    instance_name.ignore_source_directory_files = %w(time-ago)
  end

  # .
  # .
  # .
  # .
  # There can be many instances as per your requirements
  # Name of instance should not be same
end