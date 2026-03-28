class Site < ApplicationRecord
  has_many :checks, dependent: :destroy
  has_one  :latest_check, -> { order(checked_at: :desc) }, class_name: "Check"

  validates :name, presence: true
  validates :url,  presence: true,
                   format: {
                     with: /\Ahttps?:\/\/.+/,
                     message: "must begin with http:// or https://"
                   }

  def status_color
    return "dim" unless latest_check
    (200..299).include?(latest_check.status) ? "up" : "down"
  end

  def status_label
    return "PENDING" unless latest_check
    (200..299).include?(latest_check.status) ? "UP" : "DOWN"
  end
end
