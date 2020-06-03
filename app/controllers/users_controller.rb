class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  before_action :admin_or_correct_user, only: [:index, :show, :edit_one_month]
  
    def index
      #条件分岐
      @users = if params[:search]
      #searchされた場合は、原文+.where('name LIKE ?', "%#{params[:search]}%")を実行
      User.paginate(page: params[:page]).search(params[:search])
        else
      #searchされていない場合は、原文そのまま
      User.paginate(page: params[:page], per_page: 20)
        end
    end
    
    def import
      # fileはtmpに自動で一時保存される
      if params[:file].blank?
         flash[:danger] = "CSVファイルが選択されてません。"
      else User.import(params[:file])
         flash[:success] = "インポートしました。"
      end
         redirect_to users_url
    end
    
    def attendance_work
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
      @attendance = Attendance.find(params[:id])
      @worked_sum = @attendances.where.not(started_before_at: nil).size
      @superior = User.where(superior: true).where.not(id: current_user)
      all_attendance = Attendance.all
      #残業申請の件数
      @over_sum =  all_attendance.where(mark_instructor_confirmation: "申請中").where(attendances: {instructor_confirmation: @user.name}).size
      #勤怠変更申請の件数
      @change_sum = all_attendance.where(mark_change_confirmation: "申請中").where(attendances: {change_confirmation: @user.name}).size
      #１ヶ月分勤怠申請の件数
      @apploval_sum = all_attendance.where(mark_apploval_confirmation: "申請中").where(attendances: {apploval_confirmation: @user.name}).size
      @month = Date.current.beginning_of_month
      #@months = current_user.attendances.find_by(date: @first_day)
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
         render :edit      
      end
    end
    
    def destroy
      @user.destroy
      flash[:success] = "#{@user.name}のデータを削除しました。"
      redirect_to users_url
    end
    
    def edit_basic_info
    end
  
    def update_basic_info
      if @user.update_attributes(user_info_params)
       # 更新成功時の処理
       flash[:success] = "#{@user.name}の基本情報を更新しました。"
      else
       # 更新失敗時の処理
       flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
      end
       redirect_to users_url
    end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end
    
    def user_info_params
      params.permit(:name, :email, :password, :affiliation, :employee_number, :uid, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
    
     # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      User.paginate(page: params[:page], per_page: 20)
      unless current_user.admin? || current_user?(@user)
        flash[:danger] = "権限がありません。"
        redirect_to(root_url)
      end  
    end
end 
    