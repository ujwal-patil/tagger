require "tagger/version"
require "tagger/word_counter"
require "tagger/tag"
require "tagger/instance"
require "tagger/localizer"
require "tagger/locale"
require "tagger/rails/engine"

module Tagger
  class Error < StandardError; end

  class NoInstanceConfiguredError < StandardError; end
  class NoInstanceFoundError < StandardError; end
  class FileNotFoundError < StandardError; end
  class InvalidFileUploadError < StandardError; end

  # Your code goes here...

  DEFAULT_OPTIONS = {
    file_directory_path: '',
    file_type: :json,
    keep_recent_tags: 5,
    keep_recent_releases: 5,
    ignore_source_directory_files: []
  }


  class << self
    def setup
      yield(self)
    end

    def git_branch
      class_variable_get("@@git_branch")
    end

    def git_branch=(name)
      class_variable_set("@@git_branch", name)
    end

    def parent_controller
      class_variable_get("@@parent_ctr")
    end

    def parent_controller=(name='ApplicationController')
      class_variable_set("@@parent_ctr", name)
    end

    def instances
      class_variables.map do |m|
        if ['@@parent_ctr', '@@git_branch'].exclude?(m.to_s)
          Tagger::Instance.new(class_variable_get(m), m.to_s.remove('@@')) 
        end
      end.compact
    end

    def configured_instances
      class_variables.map do |m|
        m.to_s.remove('@@') unless m.to_s == '@@parent_ctr'
      end.compact
    end

    def instance(name)
      class_variable_set("@@#{name}", OpenStruct.new(DEFAULT_OPTIONS))
      yield(class_variable_get("@@#{name}"))
    end
  end
end