Rails.application.routes.draw do
  get 'messages', to: 'messages#index'
  get 'reload_messages', to: 'messages#reload_messages'
  get 'create_sentiment_analysis', to: 'messages#create_sentiment_analysis'
  root to: 'messages#index'
  devise_for :users, only: %i[registrations sessions], controllers: { registrations: 'users/registrations' }

  namespace :api do
    get 'observed_members', to: 'observed_members#index'
    resources :slack_channels, only: %i[index] do
      scope module: :slack_channels do
        resources :members, only: %i[index]
      end
    end
  end
end
