require 'csv'

CSV.generate do |csv|

  column_names = %w(日付 出勤時間 退社時間)
  csv << column_names
  @attendances.each do |attendance|
    column_values = [
      attendance.worked_on.strftime("%m/%d"),
      if attendance.started_at.present?
         attendance.started_at.to_s(:time)
      else
         ""
      end,
      if attendance.finished_at.present?
         attendance.finished_at.to_s(:time)
      else
         ""
      end
    ]
    csv << column_values
  end
end