class PingAllSitesJob < ApplicationJob
  queue_as :default

  def perform
    Site.includes(:latest_check).find_each do |site|
      if site.latest_check.nil? || site.latest_check.checked_at <= site.check_interval_seconds.seconds.ago
        PingSiteJob.perform_later(site.id)
      end
    end
  end
end
