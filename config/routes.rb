Rails.application.routes.draw do
  root 'components#index'
  post 'home/ask'
  get 'home/load'
end
