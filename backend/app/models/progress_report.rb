class ProgressReport < ApplicationRecord
  belongs_to :workspace
  belongs_to :user

  validates :workspace_id, uniqueness: { scope: :user_id }
end
