Rails.application.routes.draw do
  get 'welcome/index'
  root to: 'welcome#index'
  devise_for :users, only: :registrations
end
