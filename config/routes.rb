Tagger::Engine.routes.draw do
  resources :instances, instance_id: Regexp.union(Tagger.instances.map(&:name)), only: [:index] do
    resources :locales, controller: 'tagger/locales' do
      member do
         get :delta
         get :complete
        post :upload
      end
    end

    collection do
      put :update
    end
  end

  get '(/*path)' => 'tagger/instances#index'
end
