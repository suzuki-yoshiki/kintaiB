class AddChangeMonthToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_month, :datetime
    add_column :attendances, :overtime_month, :datetime
  end
end
