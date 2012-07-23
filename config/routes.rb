Tsa::Application.routes.draw do
  match 'login', to: 'sessions#new', via: :get
  match 'login', to: 'sessions#create', via: :post
  match 'logout', to: 'sessions#destroy'
  match 'proxyValidate', to: 'sessions#proxy_validate'
end
