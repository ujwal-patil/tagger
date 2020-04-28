require "tagger/version"
require "tagger/file"
require "tagger/instance"
require "tagger/locale"
require "tagger/rails/engine"

module Tagger
  class Error < StandardError; end

  class NoInstanceConfiguredError < StandardError; end
  class NoInstanceFoundError < StandardError; end

  # Your code goes here...

  DEFAULT_OPTIONS = {
    file_directory_path: '',
    file_type: :json,
    keep_recent_tags: 10
  }



  class << self
    def setup
      yield(self)
    end

    def parent_controller
      class_variable_get("@@parent_ctr")
    end

    def parent_controller=(name='ApplicationController')
      class_variable_set("@@parent_ctr", name)
    end

    def instances
      class_variables.map do |m|
        Tagger::Instance.new(class_variable_get(m), m.to_s.remove('@@')) unless m.to_s == '@@parent_ctr'
      end.compact
    end

    def instance(name)
      class_variable_set("@@#{name}", OpenStruct.new(DEFAULT_OPTIONS))
      yield(class_variable_get("@@#{name}"))
    end
  end
end