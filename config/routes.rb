Rails.application.routes.draw do
  get 'messages', to: 'messages#index'
  root to: 'messages#index'
  devise_for :users, only: %i[registrations sessions], controllers: { registrations: 'users/registrations' }

  namespace :api do
    get 'observed_members', to: 'observed_members#index'
  end
end
