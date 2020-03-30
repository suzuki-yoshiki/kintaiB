class AddSearchToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :search, :string
  end
end
