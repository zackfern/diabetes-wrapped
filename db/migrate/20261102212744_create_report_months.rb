class CreateReportMonths < ActiveRecord::Migration[8.1]
  def change
    create_table :report_months do |t|
      t.belongs_to :report, null: false, foreign_key: true
      t.integer :month, null: false
      t.string :status, default: "in_progress"
      t.integer :total_insulin
      t.integer :total_basal
      t.integer :total_bolus
      t.integer :highest_bg
      t.date :highest_bg_date
      t.integer :lowest_bg
      t.date :lowest_bg_date
      t.integer :days_in_range
      t.integer :biggest_bolus
      t.date :biggest_bolus_date
      t.integer :bolus_count

      t.timestamps
    end
  end
end
