ThamesTimeLapse::Application.routes.draw do
  root 'images#index'
  resources :images, only: [:index, :show]
end
