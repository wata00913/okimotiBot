Rails.application.routes.draw do
  get 'messages', to: 'messages#index'
  get 'welcome/index'
  root to: 'welcome#index'
  devise_for :users, only: %i[registrations sessions]
end
