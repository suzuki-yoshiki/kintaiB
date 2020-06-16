require 'csv'

CSV.generate do |csv|

  column_names = %w(日付 曜日 出勤時間 退社時間)
  csv << column_names
  @attendances.each do |day|
    column_values = [
      day.worked_on.strftime("%m/%d"),
      $days_of_the_week[day.worked_on.wday],
      if day.started_at.present?
         l(day.started_at.floor_to(60*15), format: :time)
      else
         ""
      end,
      if day.finished_at.present?
          l(day.finished_at.floor_to(60*15), format: :time)
      else
         ""
      end
    ]
    csv << column_values
  end
end