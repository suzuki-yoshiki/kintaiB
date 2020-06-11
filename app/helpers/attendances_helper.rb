module AttendancesHelper
  
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_before_at.nil? 
      return '退勤' if attendance.started_before_at.present? && attendance.finished_before_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
    # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。翌日
  def working_tommorow_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0) + 24.0)
  end
  
  #指定勤務終了時間と終了予定時間を受け取り、時間外時間を計算して返します。
  def over_times(start, finish, time)
    if start.hour < 12
      format("%.2f", (((finish - start) / 60) / 60.0) - (((time.hour * 60) + time.min) / 60.0) - 1)
    else
      format("%.2f", (((finish - start) / 60) / 60.0) - (((time.hour * 60) + time.min) / 60.0))
    end  
  end
  
  #時間を１５分区切る。
  def format_min(time)
    format("%.2d",(((time.min) / 15) * 15))
  end

  # 残業翌日時間を計算して返します。false
  def today_times(start, finish, time)
    format("%.2f", (((finish - (start + (finish.beginning_of_day - start.beginning_of_day))) / 60) / 60.0))
  end  
  
  # 残業翌日時間を計算して返します。true
  def tomorrow_times(start, finish, time)
    format("%.2f", (((finish - (start + (finish.beginning_of_day - start.beginning_of_day))) / 60) / 60.0) + 24.0)
  end
  
end
