# Tagger

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tagger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tagger

## Usage
Tagger is useful for calculating delta diff between json or yml files, and it is basically useful to manage translations string for localization purpose.
When your application grow, simulteniously your language strings file size also increases, and then it will become a pain for Maintainers or Owners. For that reason I have introduced this basic diff calculator on temp basis.

To configure for your managed locale JSON or YAML files, continue following steps

1) Setup Configuration instances for your application in following generated file
```ruby 
   config/initializers/tagger.rb 
``` 

```ruby
Tagger.setup do |config|

  config.parent_controller = 'ApplicationController'
  # Configure git Branch where you want to push your state of application after updating.
  config.git_branch = ENV['LOCALIZER_BRANCH']

  config.instance(:user) do |user_dashboard|
    # file_directory_path - Where your locale json files are located
    user_dashboard.file_directory_path = Rails.root.join('app/assets/javascripts/dashboard-v2/locale')

    # file type like json, yaml etc.
    user_dashboard.file_type = :json

    # keep_recent_tags - This will keep only 3 recent tag versions
    user_dashboard.keep_recent_tags = 3

    # keep_recent_releases - will keep 3 recent releases of each locale root file
    # in /releases/ directory relative to specified source_directory_path.
    user_dashboard.keep_recent_releases = 3

    # once you upload file, all invalid unnecessary files in source_directory_path will be deleted.
    # If you wants to prevent files from source dir, add name of file in ignore_source_directory_files array
    user_dashboard.ignore_source_directory_files = %w()
  end

  config.instance(:reseller) do |reseller_dashboard|
    # file_directory_path - Where your locale json files are located
    reseller_dashboard.file_directory_path = Rails.root.join('app/assets/javascripts/reseller-dashboard/locale')

    # file type like json, yaml etc.
    reseller_dashboard.file_type = :json

    # keep_recent_tags - This will keep only 3 recent tag versions
    reseller_dashboard.keep_recent_tags = 3

    # keep_recent_releases - will keep 3 recent releases of each locale root file
    # in /releases/ directory relative to specified source_directory_path.
    reseller_dashboard.keep_recent_releases = 3

    # once you upload file, all invalid unnecessary files in source_directory_path will be deleted.
    # If you wants to prevent files from source dir, add name of file in ignore_source_directory_files array
    reseller_dashboard.ignore_source_directory_files = %w()
  end

  config.instance(:server) do |server|
    # file_directory_path - Where your locale json files are located
    server.file_directory_path = Rails.root.join('config/locales')

    # file type like json, yaml etc.
    server.file_type = :yml

    # keep_recent_tags - This will keep only 10 recent tag versions
    server.keep_recent_tags = 3

    # keep_recent_releases - will keep 3 recent releases of each locale root file
    # in /releases/ directory relative to specified source_directory_path.
    server.keep_recent_releases = 3

    # once you upload file, all invalid unnecessary files in source_directory_path will be deleted.
    # If you wants to prevent files from source dir, add name of file in ignore_source_directory_files array
    server.ignore_source_directory_files = %w(time-ago)
  end
end
```
2) Once done, restart your server
3) Create your project user who is responsible to update/access the strings using portal
```ruby 
   rails tagger:create <email>
```
4) Login to your application using the same username
5) Navigate the following URL to access the tagger portal
  ```ruby 
    <BASE_URL>/tagger 
  ```
6) You can use the available portal to Download -> Translate the english delta -> Upload the translated file again to update translated strings
  ![image](https://user-images.githubusercontent.com/28054599/184151631-665910b5-0db7-4a09-b0e1-badf115b4d60.png)

7) There might be a problem you may face in large products like,

   Ex. In Large products there are many sprints in ongoing development, but we do update translations only on querter basis 
   so that will create conflicts problem while merging many received files from Translator Vendors, that issues also tagger will auto takes care
   You can see the generated tags for the delta downloaded files, these are the recorded save points, which will auto take care your diff from 
   various sprint releases. You can select any save point and download the delta file from a particular release point.
