class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :name,  presence: true

  has_many :workspace_users, dependent: :destroy
  has_many :workspaces, through: :workspace_users
end

