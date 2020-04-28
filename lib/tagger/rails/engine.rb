module Tagger
  module Rails
    class Engine < ::Rails::Engine
      initializer :assets, group: :all do
        ::Rails.application.config.assets.precompile +=  %w(jquery.range-min.js jquery.range.css tagger.scss)
      end
    end
  end
end