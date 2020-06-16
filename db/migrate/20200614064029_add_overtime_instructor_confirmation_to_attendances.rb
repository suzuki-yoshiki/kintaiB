class AddOvertimeInstructorConfirmationToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_instructor_confirmation, :string
    add_column :attendances, :edit_change_confirmation, :string
  end
end
