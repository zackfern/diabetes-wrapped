class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :slug, null: false
      t.string :status, default: "not_started"

      t.timestamps
    end
  end
end
