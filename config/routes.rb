Rails.application.routes.draw do
  namespace :api do
    get '/features', to: 'earthquake#index'
    post '/features/:id/comments', to: 'earthquake#create_comment'
    # resources :earthquakes
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
