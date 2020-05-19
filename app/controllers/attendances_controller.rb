class AttendancesController < ApplicationController
  
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_log, :edit_overtime_info, :new_overtime_info, :apploval_one_month_info, :change_request_info, :apploval_request]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判別
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def show_work_time
    @attendances = Attendance.all
    respond_to do |format|
     format.html
      #html用の処理を書く
      format.csv do
         send_data render_to_string, filename: "show_work_time.csv", type: :csv
      end
    end
  end
  
  #残業申請の内容
  def edit_overtime_info
    @attendance = current_user.attendances.find_by(worked_on: params[:date])
    @superior = User.where(superior: true).where.not(id: current_user)
  end
  
  #残業申請のお知らせモーダル
  def new_overtime_info
    @user = User.joins(:attendances).group("users.id").where.not(attendances: {finished_plan_at: nil})
    @attendance = Attendance.where.not(finished_plan_at: nil)
    @superior = User.where(superior: true).where.not(id: current_user)
  end

  #残業申請
  def request_overtime
    @attendance = Attendance.find(params[:id])
    if params[:attendance][:finished_plan_at].blank? || params[:attendance][:instructor_confirmation].blank?
      flash[:danger] = "必須箇所が空欄です。"
    else @attendance.update_attributes(overtime_params)
      flash[:success] = "残業申請しました。"
    end
    redirect_to user_url(current_user)
  end
  
  #残業申請の返信
  def new_overtime
    new_overtime_params.each do |id, item|
     attendance = Attendance.find(id)
      if attendance.change == "1"
         attendance.update_attributes(item)
          flash[:success] = "変更チェックした申請内容を登録しました。"
      else
          flash[:danger] = "変更をチェックしてください。"
      end
    end
        redirect_to user_url(current_user)
  end
  
  #１ヶ月分勤怠申請
  def apploval_request
    @attendance = Attendance.find(params[:id])
    if @attendance[:apploval_confirmation].blank?
       flash[:danger] = "承認申請できませんでした。"
    else @attendance.update.attributes(apploval_one_month_params)
       flash[:success] = "承認申請しました。"
    end
       redirect_to user_url(current_user)
  end
  
  #１ヶ月分勤怠申請モーダル
  def apploval_one_month_info
    @user = User.joins(:attendances).group("users.id")
    @attendance = Attendance.where.not(apploval_month: nil).order(user_id: "ASC")
  end
  
  #１ヶ月分勤怠申請の返信
  def apploval_one_month
  end
  
  #勤怠変更申請モーダル
  def change_request_info
    @user = User.joins(:attendances).group("users.id")
    @attendance = Attendance.where.not(finished_at: nil).order(user_id: "ASC", worked_on: "ASC")
  end
  
  #勤怠変更申請の返信
  def change_request
  end
  
  def edit_one_month
    @superior = User.where(superior: true).where.not(id: current_user)
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:finished_at].present? && item[:started_at].blank?
            flash[:danger] = "出勤時間が入力されてません"
            redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
        elsif item[:finished_at].blank? && item[:started_at].present?
            flash[:danger] = "退勤時間が入力されてません"
            redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
        end
        attendance.update_attributes!(item)
        end
        flash[:success] = "勤怠変更申請をしました。"
        redirect_to user_url(date: params[:date]) and return
        rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
            flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
        end
        redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
  end
  
  def edit_log
  end
    
    
  
  
  private
    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :instructor_confirmation, :tomorrow])[:attendances]
    end
    #残業申請
    def overtime_params
      params.require(:attendance).permit(:finished_plan_at, :tomorrow, :business_process_content, :instructor_confirmation)
    end
    #残業承認
    def new_overtime_params
      params.require(:user).permit(attendances: [:mark_instructor_confirmation, :change])[:attendances]
    end
    #勤怠変更申請
    def change_request_params
      params.require(:user).permit(attendances: [:mark_change_confirmation, :change])[:attendances]
    end
    #１ヶ月分勤怠申請
    def apploval_one_month_params
      params.require(:user).permit(attendances: [:mark_apploval_confirmation, :apploval_confirmation, :apploval_month])[:attendances]
    end
    # beforeフィルター
    
    #   paramsハッシュからユーザーを取得します。
    def set_user
      @user = User.find(params[:user_id])
    end
    
    def set_attendance
      @attendance = Attendance.find(params[:id])
    end
    
    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
  
end