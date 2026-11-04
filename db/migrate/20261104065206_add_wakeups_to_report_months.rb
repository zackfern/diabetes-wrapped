class AddWakeupsToReportMonths < ActiveRecord::Migration[8.1]
  def change
    add_column :report_months, :wake_ups, :integer
    add_column :reports, :wake_ups, :integer
  end
end
