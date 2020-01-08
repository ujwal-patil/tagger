class InstancesController < Tagger.parent_controller.constantize

	def index
		@tags = Tagger::File.new(params[:locale], instance).tags
		
	end

	def delta
		file = Tagger::File.new(delta_params[:locale], instance).delta(delta_params[:range])
		send_file file, filename: filename
	end

	def tag
		if Tagger::File.new(params[:locale], instance).tag?
			render json: {message: "#{params[:locale]} file tagged successfully."}, status: :ok
		else
			render json: {message: "No change detected in #{params[:locale]} file"}, status: :ok
		end
	end

	private

	def delta_params
		params.require(:instance).permit(:locale, :range)
	end

	def instance
		params[:instance] && (raise Tagger::NoInstanceFoundError.new("instance not found!"))
	end
end