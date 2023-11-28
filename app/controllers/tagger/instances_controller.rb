class Tagger::InstancesController < Tagger::ApplicationController
  include Tagger::Engine.routes.url_helpers
  
  def index
    
  end

  def update
    @success = system('git reset --hard') && system('git pull --no-edit origin master')
  end

end