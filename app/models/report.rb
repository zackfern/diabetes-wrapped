class Report < ApplicationRecord
  belongs_to :user
  enum :status, [ :not_started, :in_progress, :finished ]
end
