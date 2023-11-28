class Tagger::ApplicationController < Tagger.parent_controller.constantize
  before_action :authorize_user
  layout "tagger/application" 

  protected
  
  def instance_name
    params[:instance_id] || (raise Tagger::NoInstanceFoundError.new("instance not found!"))
  end

  def authorize_user
    if Tagger.authorizer
      send(Tagger.authorizer)
    end
  end
end