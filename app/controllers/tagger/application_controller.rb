class Tagger::ApplicationController < Tagger.parent_controller.constantize
  before_action :authorize_tagger_user
  layout "tagger/application" 

  protected
  
  def instance_name
    params[:instance_id] || (raise Tagger::NoInstanceFoundError.new("instance not found!"))
  end

  def authorize_tagger_user
    defined?(super) && super
  end
end