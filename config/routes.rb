Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "wrapped/:slug" => "reports#show", as: :report
  get "wrapped/:slug/download" => "reports#download", as: :report_download
  get "wrapped/:slug/status.json" => "reports#status", as: :report_status

  resources :users, except: [ :index, :destroy ]
  get "login/:token" => "users#login", as: :login
  get "logout" => "users#logout"

  # Defines the root path route ("/")
  root "site#index"
end
