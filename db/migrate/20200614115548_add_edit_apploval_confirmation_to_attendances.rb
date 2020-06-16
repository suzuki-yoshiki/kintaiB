class AddEditApplovalConfirmationToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_apploval_confirmation, :string
  end
end
