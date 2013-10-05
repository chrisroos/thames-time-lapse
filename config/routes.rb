ThamesTimeLapse::Application.routes.draw do
  root 'images#index'
  resources :images, only: [:index, :show]
  resources :days, only: [:index, :show]
  get '/stats', to: 'statistics#index'
end
