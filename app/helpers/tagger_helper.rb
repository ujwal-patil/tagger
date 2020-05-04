module TaggerHelper
	def flash_message(id)
		if flash[:success] && id == flash[:success]['id']
			%Q{<div class="alert-message alert-success">#{flash[:success]['message']}</div>}.html_safe
		elsif flash[:error] && id == flash[:error]['id']
			%Q{<div class="alert-message alert-danger">#{flash[:error]['message']}</div>}.html_safe
		end
	end
end