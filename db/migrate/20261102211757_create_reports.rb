class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :year, default: 2026
      t.string :slug, null: false
      t.integer :status
      t.boolean :include_insulin

      t.timestamps
    end
  end
end
