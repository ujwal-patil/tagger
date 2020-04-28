class Tagger::LocalesController < Tagger.parent_controller.constantize
	layout "tagger"


	def index
		# @tags = Tagger::File.new(params[:locale], instance_name).tags
	end

	def delta
		file = Tagger::File.new(locale, instance_name).delta(delta_params[:range])
		send_file(file, filename: filename)
	end

	def complete
		tagger_file = Tagger::File.new(locale, instance_name)
		file_name = "#{instance_name}-complete-#{locale}.#{tagger_file.instance.file_type}"

		send_file(tagger_file.current_file_path, filename: file_name)
	end

	def tag
		if Tagger::File.new(locale, instance_name).tag
			render json: {message: "#{locale} file tagged successfully."}, status: :ok
		else
			render json: {message: "No change detected in #{locale} file"}, status: :ok
		end
	end

	private

	def delta_params
		params.require(:instance).permit(:range)
	end

	def instance_name
		params[:instance_id] || (raise Tagger::NoInstanceFoundError.new("instance not found!"))
	end

	def locale
		params[:id]
	end
end