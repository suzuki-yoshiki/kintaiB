class UsersController < ApplicationController
  before_action :set_user, only: [:show, :confirmation_check, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: [:show, :confirmation_check]
  before_action :admin_or_correct_user, only: [:show, :edit_one_month]
  #before_action :admin_user_return, only: :show
  before_action :limitation_login_user, only: [:new, :login, :create]
  
    def index
      #条件分岐
      @users = if params[:search]
      #searchされた場合は、原文+.where('name LIKE ?', "%#{params[:search]}%")を実行
      User.paginate(page: params[:page]).search(params[:search])
        else
      #searchされていない場合は、原文そのまま
      User.all
        end
    end
    
    def import
      # fileはtmpに自動で一時保存される
      if params[:file].blank?
         flash[:danger] = "CSVファイルが選択されてません。"
      elsif File.extname(params[:file].original_filename) != ".csv"
            flash[:danger] = "CSVファイルのみ選択してください。"
      else User.import(params[:file])
         flash[:success] = "インポートしました。"
      end
         redirect_to users_url
    end
    
    def attendance_work
      redirect_to action: "show" unless current_user.admin?
       @work_users = []
        User.all.each do |user|
          if user.attendances.any?{|a|
            (Date.today &&
            a.started_at.present? && 
            a.finished_at.blank?)}
          @work_users.push(user)
          end
        end
    end   
    
    def show
      redirect_to action: "index" if current_user.admin?
      #@attendance = Attendance.find(params[:id])
      @worked_sum = @attendances.where.not(started_at: nil).size
      @superior = User.where(superior: true).where.not(id: @user.id)
      if @user.superior?
      all_attendance = Attendance.all
      #残業申請の件数
      @over_sum =  all_attendance.where(mark_instructor_confirmation: "申請中").where(attendances: {instructor_confirmation: @user.name}).size
      #勤怠変更申請の件数
      @change_sum = all_attendance.where(mark_change_confirmation: "申請中").where(attendances: {change_confirmation: @user.name}).size
      #１ヶ月分勤怠申請の件数
      @apploval_sum = all_attendance.where(mark_apploval_confirmation: "申請中").where(attendances: {apploval_confirmation: @user.name}).size
      end
      @month = params[:date].nil? ?
              Date.current.beginning_of_month : params[:date].to_date
      @attendance = Attendance.find_by(user_id: params[:id], worked_on: @month)
      #@months = current_user.attendances.find_by(date: @first_day)
      respond_to do |format|
       format.html
        #html用の処理を書く
        format.csv do
           send_data render_to_string, filename: "show.csv.ruby", type: :csv
        end
      end
    end
    
    #勤怠情報確認のボタン
    def confirmation_check
      @worked_sum = @attendances.where.not(started_at: nil).size
      @superior = User.where(superior: true).where.not(id: @user.id)
      @month = params[:date].nil? ?
              Date.current.beginning_of_month : params[:date].to_date
      @attendance = Attendance.find_by(user_id: params[:id], worked_on: @month)
    end    
    
    def new
      @user = User.new
    end
    
    def create
        @user = User.new(user_params)
      if @user.save
        log_in @user # 保存成功後、ログインします。
        flash[:success] = "新規作成に成功しました。"
        redirect_to @user
      else
        render :new
      end
    end
    
    def edit
    end
    
    def update
      if @user.update_attributes(user_params)
         flash[:success] = "ユーザー情報を更新しました。"
         redirect_to @user# 更新に成功した場合の処理を記述します。
      else
         flash[:danger] = "ユーザー情報の更新に失敗しました。"
         render :edit      
      end
    end
    
    def destroy
      @user.destroy
      flash[:success] = "#{@user.name}のデータを削除しました。"
      redirect_to users_url
    end
    
    def edit2_basic_info
      redirect_to action: "show" unless current_user.admin?
    end
    
    def edit_basic_info
    end
  
    def update_basic_info
      if params[:user][:employee_number].blank?
        flash[:danger] = "社員番号が入力されていません。"
        redirect_to users_url and return
      elsif params[:user][:uid].blank?
        flash[:danger] = "カードIDが入力されていません。"
        redirect_to users_url and return
      elsif params[:user][:basic_work_time].blank?
        flash[:danger] = "基本勤務時間が入力されていません。"
        redirect_to users_url and return
      elsif params[:user][:designated_work_start_time].blank?
        flash[:danger] = "指定勤務開始時間が入力されていません。"
        redirect_to users_url and return
      elsif params[:user][:designated_work_end_time].blank?
        flash[:danger] = "指定勤務終了時間が入力されていません。"
        redirect_to users_url and return
      end 
        if @user.update_attributes(user_info_params)
         # 更新成功時の処理
         flash[:success] = "#{@user.name}の基本情報を更新しました。"
        else
         # 更新失敗時の処理
         flash[:danger] = "更新に失敗しました。<br>" + @user.errors.full_messages.join("<br>")
        end
         redirect_to users_url
    end

  
  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end
    
    def user_info_params
      params.require(:user).permit(:name, :email, :password, :affiliation, :employee_number, :uid, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
     # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user.admin? || current_user?(@user)
        flash[:danger] = "権限がありません。"
        redirect_to(root_url)
      end  
    end
    
    def admin_user_return
      @user = User.find(params[:user_id]) if @user.blank?
        current_user.admin?
        flash[:danger] = "権限がありません。"
        redirect_to(root_url)
    end
    # ログイン状態を返します。
    def limitation_login_user
      if @current_user
        flash[:notice] = "すでにログイン状態です。"
        redirect_to root_url
      end
    end
end 
    