Rails.application.routes.draw do
 	namespace :tagger do
 		scope	":instance", instance: Regexp.union(Tagger.instances.keys) do 
		  resources :instances, only: [:index] do
		    collection do
		      get :delta
		      get :tag
		    end
		  end
 		end
 	end
end