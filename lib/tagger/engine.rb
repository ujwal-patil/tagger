class Tagger::Engine < ::Rails::Engine

  initializer :assets, group: :all do
    ::Rails.application.config.assets.precompile +=  %w(tagger.scss tagger.js)
  end
end