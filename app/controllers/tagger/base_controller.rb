class Tagger::BaseController < Tagger.parent_controller.constantize
	layout "tagger"



	protected
	
	def instance_name
		params[:instance_id] || (raise Tagger::NoInstanceFoundError.new("instance not found!"))
	end
end