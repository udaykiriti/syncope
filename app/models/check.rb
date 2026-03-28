class Check < ApplicationRecord
  belongs_to :site

  validates :status,     presence: true
  validates :checked_at, presence: true
end
