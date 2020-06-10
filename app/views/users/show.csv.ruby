require 'csv'

CSV.generate do |csv|

  column_names = %w(日付 曜日 出勤時間 退社時間)
  csv << column_names
  @attendances.each do |day|
    column_values = [
      day.worked_on.strftime("%m/%d"),
      $days_of_the_week[day.worked_on.wday],
      if day.started_before_at.present? && day.started_at.blank?
         l(day.started_before_at.floor_to(60*15), format: :time)
      elsif day.started_at.present? && day.mark_change_confirmation == "承認"
         l(day.started_at.floor_to(60*15), format: :time)
      else
         ""
      end,
      if day.finished_before_at.present? && day.finished_at.blank?
          l(day.finished_before_at.floor_to(60*15), format: :time)
      elsif day.finished_at.present? && day.mark_change_confirmation == "承認"
          l(day.finished_at.floor_to(60*15), format: :time)
      else
         ""
      end
    ]
    csv << column_values
  end
end