class AttendancesController < ApplicationController
  
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_log, :edit_overtime_info, :new_overtime_info, :new_overtime, :apploval_one_month_info, :change_request_info, :change_request, :apploval_request]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判別
    if @attendance.started_before_at.nil?
      if @attendance.update_attributes(started_before_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_before_at.nil?
      if @attendance.update_attributes(finished_before_at: Time.current.change(sec: 0))
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
    @users = User.joins(:attendances).group("users.id").where(attendances: {mark_instructor_confirmation: "申請中"}).where(attendances: {instructor_confirmation: current_user.name})
    @attendances = Attendance.where.not(finished_plan_at: nil)
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
      if item[:change] == "0" && item[:mark_instructor_confirmation] == "承認" || item[:mark_instructor_confirmation] == "否認"
         flash[:danger] = "変更チェックが必要です。"
      elsif
         item[:change] == "0" && item[:mark_instructor_confirmation] == "なし" || item[:mark_instructor_confirmation] == "申請中"
         flash[:danger] = "変更チェックと承認か否認の選択が必要です。"
      elsif
         item[:change] == "1" && item[:mark_instructor_confirmation] == "承認" || item[:mark_instructor_confirmation] == "否認"
         attendance.update_attributes(item)
         flash[:success] = "申請内容を登録しました。"
      end
    end
        redirect_to user_url(current_user)
  end
  
  #１ヶ月分勤怠申請
  def apploval_one_month
    apploval_one_month_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:apploval_confirmation].present?
         attendance.update_attributes(item)
         flash[:success] = "１ヶ月分の勤怠を申請しました。"
      else
         flash[:danger] = "１ヶ月分勤怠申請できません。"
      end
    end
        redirect_to user_url(current_user)
  end  
  
  #１ヶ月分勤怠申請モーダル
  def apploval_one_month_info
    @users = User.joins(:attendances).group("users.id").where(attendances: {mark_apploval_confirmation: "申請中"}).where(attendances: {apploval_confirmation: current_user.name})
    @attendances = Attendance.where.not(apploval_month: nil)
    @month = Date.current.beginning_of_month
  end
  
  #１ヶ月分勤怠申請の返信
  def apploval_request
    apploval_request_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:change] == "0" && item[:mark_apploval_confirmation] == "承認" || item[:mark_apploval_confirmation] == "否認"
         flash[:danger] = "変更チェックが必要です。"
      elsif
         item[:change] == "0" && item[:mark_apploval_confirmation] == "なし" || item[:mark_apploval_confirmation] == "申請中"
         flash[:danger] = "変更チェックと承認か否認を選択してください。"
      elsif
         item[:change] == "1" && item[:mark_apploval_confirmation] == "承認" || item[:mark_apploval_confirmation] == "否認"
         attendance.update_attributes(item)
         flash[:success] = "１ヶ月分勤怠申請を返信しました。"
      end
    end
       redirect_to user_url(current_user)
  end
  
  #勤怠変更申請モーダル
  def change_request_info
    @users = User.joins(:attendances).group("users.id").where(attendances: {mark_change_confirmation: "申請中"}).where(attendances: {change_confirmation: current_user.name})
    @attendances = Attendance.where.not(finished_at: nil)
  end
  
  #勤怠変更申請の返信
  def change_request
    change_request_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:change] == "0" && item[:mark_change_confirmation] == "承認" || item[:mark_change_confirmation] == "否認"
         flash[:danger] = "変更チェックが必要です"
      elsif
         item[:change] == "0" && item[:mark_change_confirmation] == "申請中" || item[:mark_change_confirmation] == "なし"
         flash[:danger] = "変更チェックと承認か否認の選択が必要です"
      elsif
         item[:change] == "1" && item[:mark_change_confirmation] == "承認" || item[:mark_change_confirmation] == "否認"
         attendance.update_attributes(item)
         flash[:success] = "変更を登録しました"
      end
      redirect_to user_url(current_user) and return
    end
  end
  #勤怠変更編集
  def edit_one_month
    @superior = User.where(superior: true).where.not(id: current_user)
  end
  #勤怠変更申請
  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        if  item[:finished_at].present? && item[:started_at].blank?
            flash[:danger] = "出勤時間が入力されてません"
            redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
        elsif 
            item[:finished_at].blank? && item[:started_at].present?
            flash[:danger] = "退勤時間が入力されてません"
            redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
        elsif
            item[:change_confirmation].present? && item[:finished_at].blank? && item[:started_at].blank?
            flash[:danger] = "出勤、退勤時間を入力してください"
            redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
        end
        if  item[:change_confirmation].blank? && item[:finished_at].present? && item[:started_at].present?
            flash[:danger] = "指示者確認を選択してください"
            redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
        else
        end
        attendance.update_attributes!(item)
        end
        flash[:success] = "勤怠変更申請をしました。"
        redirect_to user_url(date: params[:date]) and return
        rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
            flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
        end
        redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
  end
  
  def edit_log
    @attendances = Attendance.where.not(finished_at: nil).where(mark_change_confirmation: "承認").order("worked_on DESC")
  end
    
    
  
  
  private
    # 勤怠変更申請
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :mark_change_confirmation, :change_confirmation, :tomorrow])[:attendances]
    end
    #勤怠変更申請の返信
    def change_request_params
      params.require(:user).permit(attendances: [:mark_change_confirmation, :change])[:attendances]
    end    
    #残業申請
    def overtime_params
      params.require(:attendance).permit(:finished_plan_at, :tomorrow, :business_process_content, :instructor_confirmation, :mark_instructor_confirmation)
    end
    #残業承認
    def new_overtime_params
      params.require(:user).permit(attendances: [:mark_instructor_confirmation, :change])[:attendances]
    end
    #１ヶ月分勤怠申請
    def apploval_one_month_params
      params.require(:user).permit(attendances: [:mark_apploval_confirmation, :apploval_confirmation, :apploval_month])[:attendances]
    end
    #１ヶ月分勤怠申請の返信
    def apploval_request_params
      params.require(:user).permit(attendances: [:mark_apploval_confirmation, :apploval_confirmation, :apploval_month, :change])[:attendances]
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