class Task < ApplicationRecord
  belongs_to :workspace
  belongs_to :user   

  
  VALID_STATUSES = %w[pending in_progress completed].freeze


  validates :title, presence: true
  validates :due_date, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
end
