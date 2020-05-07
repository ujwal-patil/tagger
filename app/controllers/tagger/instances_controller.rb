class Tagger::InstancesController < Tagger::BaseController

	def index
		
	end

	def update
		@success = system('git pull --no-edit origin master')
	end

end