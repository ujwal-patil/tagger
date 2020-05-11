class Tagger::BaseController < Tagger.parent_controller.constantize
	layout "tagger"

	before_action :authorize_tagger_user

	protected
	
	def instance_name
		params[:instance_id] || (raise Tagger::NoInstanceFoundError.new("instance not found!"))
	end

	def authorize_tagger_user
		unless Tagger::User.find_by(email: current_user&.email)
			redirect_to root_path
		end
	end
end