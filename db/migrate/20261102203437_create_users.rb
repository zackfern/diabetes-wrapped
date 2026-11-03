class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :nightscout_host
      t.string :nightscout_token
      t.string :timezone
      t.float :range_min, default: 70.0
      t.float :range_max, default: 180.0

      t.timestamps
    end
  end
end
