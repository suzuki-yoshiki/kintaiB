class AddUidToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :uid, :bigint
    add_column :users, :employee_number, :integer
    add_column :users, :superior, :boolean
    add_column :users, :affiliation, :string
  end
end
