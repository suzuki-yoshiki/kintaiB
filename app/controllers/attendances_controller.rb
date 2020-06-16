class AttendancesController < ApplicationController
  
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_log, :apploval_one_month, :edit_overtime_info, :new_overtime_info, :new_overtime, :request_overtime, :apploval_one_month_info, :change_request_info, :change_request, :apploval_request]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month, :change_request_info, :edit_overtime_info]
  #before_action :admin_user, only: :show
  
  
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  UPDATE_OVERTIME_ERROR_MSG = "残業申請承認に失敗しました。やり直してください。"
  UPDATE_CHANGE_ERROR_MSG = "勤怠変更申請承認に失敗しました。やり直してください。"
  UPDATE_APPLOVAL_ERROR_MSG = "１ヶ月分承認申請承認に失敗しました。やり直してください。"


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
  
  #残業申請の内容
  def edit_overtime_info
    @attendances = current_user.attendances.find_by(worked_on: params[:date])
    @superior = User.where(superior: true).where.not(id: @user.id)
  end
  
  #残業申請のお知らせモーダル
  def new_overtime_info
    @users = User.joins(:attendances).group("users.id").where(attendances: {mark_instructor_confirmation: "申請中"}).where(attendances: {instructor_confirmation: current_user.name})
    @attendance = Attendance.where.not(finished_plan_at: nil).order("worked_on ASC")
    @superior = User.where(superior: true).where.not(id: current_user)
  end

  #残業申請
  def request_overtime
    @attendance = Attendance.find(params[:id])
      if params[:attendance][:finished_plan_at].blank?
        flash[:danger] = "終了予定時間を入力してください。"
        redirect_to @user and return
      elsif params[:attendance][:instructor_confirmation].blank?
        flash[:danger] = "指示者を入力してください。"
        redirect_to @user and return
      elsif params[:attendance][:business_process_content].blank?
        flash[:danger] = "業務処理内容を入力してください。"
        redirect_to @user and return
      end
      if params[:attendance][:tomorrow] == "1"
        tomorrow_day = @attendance.worked_on.to_date.tomorrow
        params[:attendance][:finished_plan_at] = tomorrow_day.to_s + " " + params[:attendance][:finished_plan_at] + ":00"
      else
        params[:attendance][:finished_plan_at] = @attendance.worked_on.to_s + " " + params[:attendance][:finished_plan_at] + ":00"
      end
      #if params[:attendance][:started_at] > params[:attendance][:finished_plan_at]
        #flash[:danger] = "出勤時間より早い終了予定時間は入力できません。"
      #end
    @attendance.update_attributes(overtime_params)
    flash[:success] = "残業申請しました。"
    redirect_to user_url(current_user)
  end
  
  #残業申請の返信
  def new_overtime
    ActiveRecord::Base.transaction do
      n1 = 0
      n2 = 0
      n3 = 0
      new_overtime_params.each do |id, item|
         if item[:instructor_confirmation].present?
           if (item[:change] == "1") && (item[:mark_instructor_confirmation] == "なし" || item[:mark_instructor_confirmation] == "承認" || item[:mark_instructor_confirmation] == "否認")
             attendance = Attendance.find(id)
             user = User.find(attendance.user_id)
             if item[:mark_instructor_confirmation] == "なし"
               n1 += 1
               item[:mark_instructor_confirmation] = nil
               if attendance.finished_at.present?
                 if (attendance.finished_at > attendance.worked_on) ||
                    (attendance.finished_at.hour > user.designated_work_end_time.hour) ||
                    ((attendance.finished_at.hour == user.designated_work_end_time.hour) &&
                    (attendance.finished_at.min > user.designated_work_end_time.min))
                    item[:finished_plan_at] = attendance.finished_at
                 end
               else
               item[:finished_plan_at] = nil
               end
               item[:instructor_confirmation] = nil
               item[:overtime_instructor_confirmation] = nil
               attendance.business_process_content = nil
             elsif item[:mark_instructor_confirmation] == "承認"
               n2 += 1
               if attendance.finished_before_at.blank?
                 attendance.finished_before_at = attendance.finished_at
               end
               attendance.finished_at = attendance.finished_plan_at
               item[:overtime_instructor_confirmation] = "残業承認済"
             elsif item[:mark_instructor_confirmation] == "否認"
               n3 += 1
               if attendance.finished_at.present?
                 if (attendance.finished_at > attendance.worked_on) ||
                    (attendance.finished_at.hour > user.designated_work_end_time.hour) ||
                    ((attendance.finished_at.hour == user.designated_work_end_time.hour) &&
                    (attendance.finished_at.min >  user.designated_work_end_time.min))
                    item[:finished_plan_at] = attendance.finished_at
                 end
               else
                 item[:finished_plan_at] = nil
               end
               item[:business_process_content] = nil
               item[:overtime_instructor_confirmation] = "残業否認"
             end
            item[:change] = "0"
            attendance.update_attributes(item)
           end
         end
       end
       flash[:success] = "残業申請の#{n1}件なし、#{n2}件承認、#{n3}件否認を登録しました"
       redirect_to user_url(date: params[:date]) and return
        #   if (item[:change] == "0") && (item[:mark_instructor_confirmation] == "承認" || item[:mark_instructor_confirmation] == "否認")
        #     flash[:danger] = "変更チェックが必要です。"
        #   elsif
        #     (item[:change] == "0") && (item[:mark_instructor_confirmation] == "なし" || item[:mark_instructor_confirmation] == "申請中")
        #     flash[:danger] = "変更チェックと承認か否認の選択が必要です。"
        #   elsif
        #     (item[:change] == "1") && (item[:mark_instructor_confirmation] == "承認" || item[:mark_instructor_confirmation] == "否認")
        #     attendance.update_attributes(item)
        #     flash[:success] = "申請内容を登録しました。"
        #   end
        # end
        #     redirect_to user_url(current_user)
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "UPDATE_OVERTIME_ERROR_MSG"
    redirect_to user_url(params[:id]) and return
  end
  
  #１ヶ月分勤怠申請
  def apploval_one_month
      attendance = Attendance.find(params[:id])
      if params[:attendance][:apploval_confirmation].present?
         attendance.update_attributes(apploval_one_month_params)
         flash[:success] = "１ヶ月分の勤怠を申請しました。"
      else
         flash[:danger] = "１ヶ月分勤怠申請できません。"
      end
       redirect_to user_url(current_user)
  end  
  
  #１ヶ月分勤怠申請モーダル
  def apploval_one_month_info
    @users = User.joins(:attendances).group("users.id").where(attendances: {mark_apploval_confirmation: "申請中"}).where(attendances: {apploval_confirmation: @user.name})
    @attendances = Attendance.where.not(worked_on: nil).where(mark_apploval_confirmation: "申請中").order("worked_on ASC")
  end

  #１ヶ月分勤怠申請の返信
  def apploval_request
    ActiveRecord::Base.transaction do
      a1 = 0
      a2 = 0
      a3 = 0
      apploval_request_params.each do |id, item|
        if item[:apploval_confirmation].present?
          if (item[:change_apploval] == "1") && (item[:mark_apploval_confirmation] == "なし" || item[:mark_apploval_confirmation] == "承認" || item[:mark_apploval_confirmation] == "否認") 
            attendance = Attendance.find(id)
            if item[:mark_apploval_confirmation] == "なし"
              a1 += 1
              item[:apploval_confirmation] = nil
              item[:mark_apploval_confirmation] = nil
            elsif item[:mark_apploval_confirmation] == "承認"
              a2 += 1
              item[:edit_apploval_confirmation] = "承認済"
            elsif item[:mark_apploval_confirmation] == "否認"
              a3 += 1
              item[:edit_apploval_confirmation] = "否認"
            end
            item[:change_apploval] = "0"
            attendance.update_attributes(item)
          end
        end
          # if (item[:change_apploval] == "0") && (item[:mark_apploval_confirmation] == "承認" or item[:mark_apploval_confirmation] == "否認")
          #   flash[:danger] = "変更チェックが必要です。"
          # elsif
          #   (item[:change_apploval] == "0") && (item[:mark_apploval_confirmation] == "なし" or item[:mark_apploval_confirmation] == "申請中")
          #   flash[:danger] = "変更チェックと承認か否認を選択してください。"
          # elsif
          #   (item[:change_apploval] == "1") && (item[:mark_apploval_confirmation] == "否認" or item[:mark_apploval_confirmation] == "承認")
          #   attendance.update_attributes(item)
          #   flash[:success] = "１ヶ月分勤怠申請を返信しました。"
          # end
      end
      flash[:success] = "１ヶ月分勤怠申請の#{a1}件なし、#{a2}件承認、#{a3}件否認を登録しました"
      redirect_to user_url(current_user)
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
      flash[:danger] = "UPDATE_APPLOVAL_ERROR_MSG"
      redirect_to user_url(date: params[:date]) and return
  end
  
  #勤怠変更申請モーダル
  def change_request_info
    @users = User.joins(:attendances).group("users.id").where(attendances: {mark_change_confirmation: "申請中"}).where(attendances: {change_confirmation: @user.name})
    @attendances = Attendance.where(mark_change_confirmation: "申請中").order("worked_on ASC")
  end
  
  #勤怠変更申請の返信
  def change_request
    ActiveRecord::Base.transaction do
      c1 = 0
      c2 = 0
      c3 = 0
      change_request_params.each do |id, item|
        if item[:change_confirmation].present?
          if (item[:change_at] == "1") && (item[:mark_change_confirmation] == "なし" || item[:mark_change_confirmation] == "承認" || item[:mark_change_confirmation] == "否認")
            attendance = Attendance.find(id)
            if item[:mark_change_confirmation] == "なし"
              c1 += 1
              item[:mark_change_confirmation] = nil
              item[:change_confirmation] = nil
              item[:edit_change_confirmation] = nil
              attendance.note = nil
              attendance.started_edit_at = nil
              attendance.finished_edit_at = nil
            elsif item[:mark_change_confirmation] == "承認"
              c2 += 1
              if attendance.started_before_at.blank?
                attendance.started_before_at = attendance.started_at
              end
              attendance.started_at = attendance.started_edit_at
              if attendance.finished_before_at.blank?
                attendance.finished_before_at = attendance.finished_at
              end
              attendance.finished_at = attendance.finished_edit_at
              attendance.started_edit_at = nil
              attendance.finished_edit_at = nil
              item[:edit_change_confirmation] = "勤怠編集承認済"
            elsif item[:mark_change_confirmation] == "否認"
              c3 += 1
              attendance.note = nil
              attendance.started_edit_at = nil
              attendance.finished_edit_at = nil
              item[:edit_change_confirmation] = "勤怠編集否認"
            end
            item[:change_at] = "0"
            attendance.update_attributes(item)
          end
        end
          # if (item[:change_at] == "0") && (item[:mark_change_confirmation] == "承認" || item[:mark_change_confirmation] == "否認")
          #   flash[:danger] = "変更チェックが必要です"
          # elsif
          #   (item[:change_at] == "0") && (item[:mark_change_confirmation] == "申請中" || item[:mark_change_confirmation] == "なし")
          #   flash[:danger] = "変更チェックと承認か否認の選択が必要です"
          # elsif
          #   (item[:change_at] == "1") && (item[:mark_change_confirmation] == "承認" || item[:mark_change_confirmation] == "否認")
          #   attendance.update_attributes(item)
          #   flash[:success] = "変更を登録しました"
          # end
      end
      flash[:success] = "勤怠変更申請の#{c1}件なし、#{c2}件承認、#{c3}件否認を登録しました"
      redirect_to user_url(date: params[:date]) and return
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
      flash[:danger] = "UPDATE_CHANGE_ERROR_MSG"
      redirect_to user_url(date: params[:date]) and return
  end
  
  #勤怠変更編集
  def edit_one_month
    redirect_to @user if current_user.admin?
    @superior = User.where(superior: true).where.not(id: @user.id)
  end
  #勤怠変更申請
  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
    c = 0
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:change_confirmation].present?
          if  item[:started_edit_at].blank? && item[:finished_edit_at].present?
              flash[:danger] = "出勤時間が入力されてません"
              redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
          elsif
              item[:finished_edit_at].blank? && item[:started_edit_at].present?
              flash[:danger] = "退勤時間が入力されてません"
              redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
          elsif item[:tomorrow_at] == "0" && (item[:started_edit_at] > item[:finished_edit_at])
              flash[:danger] = "出社時間より早い退社時間は入力できません。"
              redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
          elsif
              item[:note].blank?
              flash[:danger] = "備考が入力されてません"
              redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
          end
          #if params[:attendance][:tomorrow] == "1"
           # tomorrow_day = @attendance.worked_on.to_date.tomorrow
            #params[:attendance][:finished_plan_at] = tomorrow_day.to_s + " " + params[:attendance][:finished_plan_at] + ":00"
          #else
           # params[:attendance][:finished_plan_at] = @attendance.worked_on.to_s + " " + params[:attendance][:finished_plan_at] + ":00"
          #end
          item[:started_edit_at] = item[:worked_on].to_s + " " + item[:started_edit_at].to_s + ":00"
          if item[:tomorrow_at] == "1"
             tomorrow_day = item[:worked_on].to_date.tomorrow.to_s
             item[:finished_edit_at] = tomorrow_day.to_s + " " + item[:finished_edit_at].to_s + ":00"
          else
             item[:finished_edit_at] = item[:worked_on].to_s + " " + item[:finished_edit_at].to_s + ":00"
          end
          attendance.update_attributes!(item)
          c += 1
        end
      end
    flash[:success] = "勤怠変更を#{c}件申請をしました。"
    redirect_to user_url(date: params[:date]) and return
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
      flash[:danger] = "UPDATE_ERROR_MSG"
      redirect_to edit_one_month_user_attendance_url(date: params[:date]) and return
  end

  def edit_log
      if params["worked_on(1i)"].present? && params["worked_on(2i)"].present?
        year_month = "#{params["worked_on(1i)"]}/#{params["worked_on(2i)"]}"
        @day = DateTime.parse(year_month) if year_month.present?
        @attendances = @user.attendances.where(worked_on: @day.all_month).where(mark_change_confirmation: "承認")
      else
        @attendances = @user.attendances.where(mark_change_confirmation: "承認")
      end
  end

  private
    # 勤怠変更申請
    def attendances_params
      params.require(:user).permit(attendances: [:change_month, :worked_on, :started_edit_at, :finished_edit_at, :started_at, :finished_at, :note, :mark_change_confirmation, :change_confirmation, :tomorrow_at])[:attendances]
    end
    #勤怠変更申請の返信
    def change_request_params
      params.require(:user).permit(attendances: [:change_confirmation, :mark_change_confirmation, :change_at, :change_date, :edit_change_confirmation])[:attendances]
    end       
    #残業申請
    def overtime_params
      params.require(:attendance).permit(:overtime_month, :worked_on, :change, :finished_plan_at, :tomorrow, :business_process_content, :instructor_confirmation, :mark_instructor_confirmation)
    end
    #残業承認
    def new_overtime_params
      params.require(:user).permit(attendances: [:change, :finished_plan_at, :overtime_instructor_confirmation, :instructor_confirmation, :mark_instructor_confirmation])[:attendances]
    end
    #１ヶ月分勤怠申請
    def apploval_one_month_params
      params.require(:attendance).permit(:mark_apploval_confirmation, :apploval_confirmation, :apploval_month)
    end
     #１ヶ月分勤怠申請の返信
    def apploval_request_params
      params.require(:user).permit(attendances: [:edit_apploval_confirmation, :mark_apploval_confirmation, :apploval_confirmation, :apploval_month, :change_apploval])[:attendances]
    end
    # beforeフィルター
    
    #   paramsハッシュからユーザーを取得します。
    def set_user
      @user = User.find(params[:user_id])
    end
    
    def set_attendance
      @attendance = Attendance.find(params[:id])
    end
    def params_one_month
      @month = params[:date].nil? ?
              Date.current.beginning_of_month : params[:date].to_date
      @attendance = Attendance.find_by(user_id: params[:id], worked_on: @month)
    end
    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
    
    def admin_user
      @user = User.find(params[:user_id]) if @user.blank?
        current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
    end
  
end