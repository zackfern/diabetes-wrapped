class AddReadingsInRanges < ActiveRecord::Migration[8.1]
  def change
    add_column :report_months, :readings_in_range, :integer
    add_column :report_months, :readings_out_of_range, :integer
    add_column :reports, :readings_in_range, :integer
    add_column :reports, :readings_out_of_range, :integer
  end
end
