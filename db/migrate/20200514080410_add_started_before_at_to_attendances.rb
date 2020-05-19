class AddStartedBeforeAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :started_before_at, :datetime
    add_column :attendances, :finished_before_at, :datetime
  end
end
