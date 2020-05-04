Rails.application.routes.draw do
 	namespace :tagger do
		resources :instances, instance_id: Regexp.union(Tagger.instances.map(&:name)), only: [:index] do
	 		resources :locales do
		    member do
		      get :delta
		      get :complete
		      post :upload
		    end
		 	end
 		end
 	end

 	get '/tagger' => 'tagger/instances#index'
end
