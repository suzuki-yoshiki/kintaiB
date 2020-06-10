class AddChangeAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_at, :boolean
    add_column :attendances, :tomorrow_at, :boolean
    add_column :attendances, :change_apploval, :boolean
  end
end
