class AddAggregateStatsToReports < ActiveRecord::Migration[8.1]
  def change
    add_column :reports, :total_insulin, :integer
    add_column :reports, :total_basal, :integer
    add_column :reports, :total_bolus, :integer
    add_column :reports, :bolus_count, :integer
    add_column :reports, :days_in_range, :integer
  end
end
