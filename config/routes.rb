Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  get '/search', to:'users#search'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    collection { post :import }
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'edit2_basic_info'
      get 'attendance_work'
      get 'attendances/show_work_time'      
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'attendances/edit_over_time'  #残業申請
      patch 'attendances/update_over_time'
      get 'attendances/edit_request_one_month' #所属長承認申請のお知らせ
      patch 'attendances/update_request_one_month'
      get 'attendances/edit_change_request'   #勤怠変更申請のお知らせ
      patch 'attendances/update_change_request'
      get 'attendances/edit_request_overtime' #残業申請のお知らせ
      patch 'attendances/update_request_overtime'
      get 'attendances/edit_log' #勤怠ログ
    end
    resources :attendances, only: :update
    end
    resources :bases do
    end
end