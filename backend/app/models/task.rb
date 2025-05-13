class Task < ApplicationRecord
  belongs_to :workspace
  belongs_to :user   

  enum status: { pending: 'pending', in_progress: 'in_progress', completed: 'completed' }

  validates :title, :status, :due_date, presence: true
end
