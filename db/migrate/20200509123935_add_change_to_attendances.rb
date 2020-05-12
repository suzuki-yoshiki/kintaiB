class AddChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change, :boolean, default: false
    add_column :attendances, :tomorrow, :boolean, default: false
    add_column :attendances, :finished_plan_at, :datetime, default: Time.current.change(hour: 19, min: 0, sec: 0)
  end
end
