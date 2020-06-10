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
    end
  resources :attendances, only: :update do
    member do
      get 'edit_one_month'
      patch 'update_one_month'
      get 'users/confirmation_check' #勤怠確認
      get 'edit_log' #勤怠ログ   
      get 'edit_overtime_info'  #残業申請
      patch 'request_overtime'  
      patch 'apploval_request'   #所属長承認申請のお知らせ
      get 'apploval_one_month_info'  #１ヶ月分勤怠申請のモーダル
      patch 'apploval_one_month'     #１ヶ月分勤怠申請の返信
      get 'change_request_info'   #勤怠変更申請のお知らせ
      patch 'change_request'     #勤怠変更申請の返信
      get 'new_overtime_info' #残業申請のお知らせ
      patch 'new_overtime'    #残業申請の返信
    end
    end
  end
  resources :bases do
  end
end