class AddUnitToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :unit, :string
  end
end
