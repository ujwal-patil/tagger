module Tagger
  module Rails
    class Engine < ::Rails::Engine
      initializer :assets, group: :all do
        ::Rails.application.config.assets.precompile +=  %w(tagger.scss tagger.js)
      end
    end
  end
end