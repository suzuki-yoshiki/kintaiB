class AddStartedEditAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :started_edit_at, :datetime
    add_column :attendances, :finished_edit_at, :datetime
  end
end
