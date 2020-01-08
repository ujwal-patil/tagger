require "tagger/version"
require "tagger/file"
require "tagger/rails/engine"

module Tagger
  class Error < StandardError; end

  class NoInstanceConfiguredError < StandardError; end
  class NoInstanceFoundError < StandardError; end

  # Your code goes here...

  DEFAULT_OPTIONS = {
    file_directory_path: '',
    file_type: :json,
    keep_recent_tags: 10,
    parent_controller: 'ApplicationController'
  }



  class << self
    def setup
      yield(self)
    end

    def instances
      class_variables.map do |m|
        [m.to_s.remove('@@'), class_variable_get(m)]
      end.to_h.with_indifferent_access
    end

    def instance(name)
      class_variable_set("@@#{name}", OpenStruct.new(DEFAULT_OPTIONS))
      yield(class_variable_get("@@#{name}"))
    end
  end
end