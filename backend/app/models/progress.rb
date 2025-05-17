class Progress < ApplicationRecord
  belongs_to :workspace
  belongs_to :user

  validates :workspace, :user, :total, :completed, :rate, :aggregated_at, presence: true

  # workspace_id + user_id 
  validates :user_id, uniqueness: { scope: :workspace_id }
end

