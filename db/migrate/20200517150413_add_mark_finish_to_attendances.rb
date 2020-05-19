class AddMarkFinishToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :mark_finish, :string
  end
end
