Rails.application.routes.draw do
  root 'home#index'
  post 'home/ask'
  get 'home/load'
  post 'home/pdf'
end
