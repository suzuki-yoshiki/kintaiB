class AddChangeDateToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_date, :date
  end
end
