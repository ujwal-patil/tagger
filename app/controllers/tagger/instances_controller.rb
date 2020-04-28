class Tagger::InstancesController < Tagger.parent_controller.constantize
	layout "tagger"


	def index
		# @tags = Tagger::File.new(params[:locale], instance_name).tags
	end

	private
	
	def instance_name
		params[:instance] && (raise Tagger::NoInstanceFoundError.new("instance not found!"))
	end
end