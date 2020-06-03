class AddInstructorConfirmationToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :instructor_confirmation, :string
    add_column :attendances, :mark_instructor_confirmation, :integer
  end
end
