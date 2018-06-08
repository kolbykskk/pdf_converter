Rails.application.routes.draw do

  root 'static_pages#home'
  get 'oauth2callback' => 'static_pages#set_google_drive_token'
  patch '/static_pages/home' => 'static_pages#home'
  post 'static/generator' => 'static_pages#generator'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
