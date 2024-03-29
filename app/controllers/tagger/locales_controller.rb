class Tagger::LocalesController < Tagger::ApplicationController
  include Tagger::Engine.routes.url_helpers

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
    temp = Tempfile.new
    temp.puts(JSON.pretty_generate(tagger_locale.complete_json))
    temp.flush
    send_file(temp.path, filename: filename)
  end

  def upload
    begin
      ensure_valid_file?
      word_counter = tagger_locale.upload(params[:file])
      flash[:success] = {
        id: "message-#{tagger_locale.instance.name}-#{tagger_locale.code}", 
        message: "#{tagger_locale.code} File Uploaded successfully. Please note word counts. Added Word Count : #{word_counter.added_words},  Removed Word Count : #{word_counter.removed_words}."
      }
    rescue => e
      message = params[:file].nil? ? 'Please choose a file.' : "Please upload a valid .#{tagger_locale.code}.#{'json'} file."
      flash[:error] = {
        id: "message-#{tagger_locale.instance.name}-#{tagger_locale.code}", 
        message: "There was an error processing your upload! #{message}"
      }
    end
    redirect_to request.referrer
  end

  private

  def ensure_valid_file?
    return if params[:file].blank?

    unless params[:file].original_filename.end_with?(".#{tagger_locale.code}.#{'json'}")
      raise Tagger::InvalidFileUploadError.new("Invalid File uploaded.")
    end
  end

  def filename
    "#{action_name}.#{tagger_locale.instance.name}.#{locale}.json"
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