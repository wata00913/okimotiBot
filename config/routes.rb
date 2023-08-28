Rails.application.routes.draw do
  get 'messages', to: 'messages#index'
  root to: 'messages#index'
  devise_for :users, only: %i[registrations sessions]
end
