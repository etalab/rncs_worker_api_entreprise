Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/sidekiq'

  concern :v1_routes do
    get 'fiches_identite/:siren',     to: 'api/v1/fiches_identite#show'
    get 'fiches_identite/:siren/pdf', to: 'api/v1/fiches_identite#pdf'
  end

  scope :v1 do
    concerns :v1_routes
  end
end
