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
  def working_times(start_at, finish_at)
    format("%.2f", (((finish_at - start_at) / 60) / 60.0))
  end
  #指定勤務終了時間と終了予定時間を受け取り、時間外時間を計算して返します。
  def over_times(designated_work_end_time, finished_plan_at)
    format("%.2f", (((finished_plan_at - designated_work_end_time) / 60) / 60.0))
  end
  
  
  #時間を１５分区切る。
  def format_min(time)
    format("%.2d",(((time.min) / 15) * 15))
  end
  
  def tommorrow_times
    format("%.2f", (((finish - start) / 60) / 60.0) + 24)
  end
  
end
