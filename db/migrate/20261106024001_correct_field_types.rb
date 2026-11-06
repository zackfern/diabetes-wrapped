class CorrectFieldTypes < ActiveRecord::Migration[8.1]
  def change
    reversible do |direction|
      change_table :reports do |t|
        direction.up do
          [ :total_insulin, :total_basal, :total_bolus ].each do |col|
            t.change col, :float
          end
        end

        direction.down do
          [ :total_insulin, :total_basal, :total_bolus ].each do |col|
            t.change col, :integer
          end
        end
      end

      change_table :report_months do |t|
        direction.up do
          [ :total_insulin, :total_basal, :total_bolus, :biggest_bolus ].each do |col|
            t.change col, :float
          end

          [ :highest_bg_date, :lowest_bg_date, :biggest_bolus_date ].each do |col|
            t.change col, :datetime
          end
        end

        direction.down do
          [ :total_insulin, :total_basal, :total_bolus, :biggest_bolus ].each do |col|
            t.change col, :integer
          end

          [ :highest_bg_date, :lowest_bg_date, :biggest_bolus_date ].each do |col|
            t.change col, :date
          end
        end
      end
    end
  end
end
