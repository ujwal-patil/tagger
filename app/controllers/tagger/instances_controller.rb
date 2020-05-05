class Tagger::InstancesController < Tagger::BaseController

	def index
		
	end

	def update
		@success = system('git pull origin master')
	end

end