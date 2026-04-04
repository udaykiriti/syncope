class Site < ApplicationRecord
  has_many :checks, dependent: :destroy
  has_one  :latest_check, -> { order(checked_at: :desc) }, class_name: "Check"

  validates :name, presence: true
  validates :url,  presence: true,
                   format: {
                     with: /\Ahttps?:\/\/.+/,
                     message: "must begin with http:// or https://"
                   }

  validates :check_interval_seconds, numericality: { greater_than_or_equal_to: 60, only_integer: true }
  validates :alert_email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, allow_blank: true

  def status_color
    return "dim" unless latest_check
    up?(latest_check) ? "up" : "down"
  end

  def status_label
    return "PENDING" unless latest_check
    up?(latest_check) ? "UP" : "DOWN"
  end

  # Returns the two most recent checks as a plain Array (newest first).
  # BUG FIX: using .to_a so we load once and avoid inconsistent AR relation
  # behaviour — calling .last on a relation with .limit reverses the ORDER BY,
  # which can return the wrong record depending on Rails version.
  def two_latest_checks
    checks.order(checked_at: :desc).limit(2).to_a
  end

  # Returns :went_down, :recovered, or nil based on the last two checks.
  # BUG FIX: consolidated so both transition predicates share one DB round-trip
  # instead of each calling two_latest_checks independently.
  def status_transition
    recent = two_latest_checks
    return nil if recent.empty?

    # BUG FIX: If this is the very first check and it's down, alert immediately.
    if recent.size == 1
      return up?(recent[0]) ? nil : :went_down
    end

    # recent[0] = newest check, recent[1] = previous check
    previous_up  = up?(recent[1])
    current_up   = up?(recent[0])

    if previous_up && !current_up
      :went_down
    elsif !previous_up && current_up
      :recovered
    end
  end

  def just_went_down?  = status_transition == :went_down
  def just_recovered?  = status_transition == :recovered

  # Returns true if the given transition status needs an alert.
  # BUG FIX: Prevents duplicate alerts by checking the last alerted status.
  def needs_alert?(transition)
    last_alerted_status != transition.to_s
  end

  # Uptime percentage based on total check history.
  # BUG FIX: single SQL with AVG instead of two separate COUNT queries.
  # TODO: (Phase 6) accept a `since:` argument for time-scoped uptime windows
  # (e.g. last 7 / 30 / 90 days) as required by the analytics phase.
  def uptime_percentage
    # BUG FIX: Single SQL query with AVG and CASE is much faster for large histories.
    percentage = checks.average("CASE WHEN status BETWEEN 200 AND 299 THEN 100.0 ELSE 0.0 END")
    percentage&.round(1)
  end

  private

  def up?(check)
    (200..299).include?(check.status)
  end
end
