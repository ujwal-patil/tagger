class Tagger::InstancesController < Tagger::BaseController

	def index
		
	end

	def update
		@success = system('git reset --hard') && system('git pull --no-edit origin master')
	end

end