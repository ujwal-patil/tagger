class Tagger::LocalesController < Tagger::BaseController

	def index
		# @tags = Tagger::Locale.new(params[:locale], instance_name).tags
	end

	def delta
		data = tagger_locale.delta(params[:from_tag])
		if data.is_a?(Hash)
			temp = Tempfile.new
			temp.puts(data.to_json)
			temp.flush

			file_path = temp.path
		else
			file_path = data
		end

		send_file(file_path, filename: filename)
	end

	def complete
		send_file(tagger_locale.current_file_path, filename: filename)
	end

	def upload
		tagger_locale.upload(params[:file])
	end

	private

	def filename
		"#{instance_name}-#{action_name}-#{locale}.#{tagger_locale.instance.file_type}"
	end

	def tagger_locale
		@tagger_locale ||= Tagger::Locale.new(locale, instance_name)
	end

	def delta_params
		params.require(:instance).permit(:range)
	end

	def locale
		params[:id]
	end
end