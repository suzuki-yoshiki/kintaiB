class AddApplovalMonthToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :apploval_month, :datetime
    add_column :attendances, :mark_apploval_confirmation, :string
    add_column :attendances, :mark_change_confirmation, :string
    add_column :attendances, :apploval_confirmation, :string
    add_column :attendances, :change_confirmation, :string
  end
end
