Rails.application.routes.draw do
  devise_for :users
  resources :credentials, path_names: { new: 'upload' } do
    collection do
      get :key_info
      post :edit_multiple
      put :update_multiple
    end
  end

  controller :application do
    get '/authorized_keys/:username(/:host)' => :authorized_keys, host: %r{[^\/]+}, as: :authorized_keys
    post '/register/:host' => :register_host, host: %r{[^\/]+}, as: :register_host
    get '/x-tree/F5Monitor' => :f5_health_check, defaults: { format: :html } if ENV['F5_HEALTHCHECK']
  end

  root 'credentials#index'
end
