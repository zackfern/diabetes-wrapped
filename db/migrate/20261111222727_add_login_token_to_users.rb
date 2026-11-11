class AddLoginTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :login_token, :string
  end
end
