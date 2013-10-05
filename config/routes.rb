ThamesTimeLapse::Application.routes.draw do
  root 'images#index'
  resources :images, only: [:index, :show]
  resources :days, only: [:index]
  get '/stats', to: 'statistics#index'
  get '/:date', to: 'days#show', as: 'day'
end
