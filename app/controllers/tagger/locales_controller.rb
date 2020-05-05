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

	def show
		@tagger_locale = tagger_locale

		render partial: 'tagger/locales/locale', 
			locals: {
				instance: @tagger_locale.instance, 
				locale: @tagger_locale
			},
			layout: false
	end

	def complete
		send_file(tagger_locale.current_file_path, filename: filename)
	end

	def upload
    begin
      word_counter = tagger_locale.upload(params[:file])
      flash[:success] = {
      	id: "message-#{tagger_locale.instance.name}-#{tagger_locale.code}", 
      	message: "#{tagger_locale.code} File Uploaded successfully. Please note word counts. Added Word Count : #{word_counter.added_words},  Removed Word Count : #{word_counter.removed_words}."
      }
    rescue => e
      message = params[:file].nil? ? 'Please choose a file.' : 'Please upload a valid file.'
      flash[:error] = {
      	id: "message-#{tagger_locale.instance.name}-#{tagger_locale.code}", 
      	message: "There was an error processing your upload! #{message}"
      }
    end

    redirect_to tagger_path
	end

	private

	def filename
		"#{instance_name}-#{action_name}.#{locale}.#{tagger_locale.instance.file_type}"
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