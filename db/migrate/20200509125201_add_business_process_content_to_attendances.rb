class AddBusinessProcessContentToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :business_process_content, :string
  end
end
