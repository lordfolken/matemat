Matemat::Application.routes.draw do
  get '/users/login' => 'users#touch_login', :as => :touch_login
  post '/users/login' => 'users#do_touch_login', :as => :touch_login

  resources :users, :user_sessions

  resources :orders do
    resources :items, except: [:index, :edit, :update, :show]
    get ':id/paid' => 'items#set_paid', :as => :set_paid
  end
  get 'orders/:id/close' => 'orders#close', :as => :close_order

  namespace :admin do
    resources :products
    resources :users do
      resources :bookings
    end

    resources :pizzerias do
      resources :pizzas
    end
  end

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout

  match 'bookings' => 'bookings#create', :as => :bookings, via: [:get, :post]

  root to: 'users#index'

  if Rails.env == 'production'
    # default route to catch 404s
    match '*a', :to => 'application#render_404'
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
