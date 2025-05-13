
class Workspace < ApplicationRecord
  has_many :workspace_users, dependent: :destroy
  has_many :users, through: :workspace_users
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
end
