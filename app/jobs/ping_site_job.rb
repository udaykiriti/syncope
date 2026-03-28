class PingSiteJob < ApplicationJob
  queue_as :default

  def perform(site_id)
    site = Site.find_by(id: site_id)
    return unless site

    result = SitePinger.ping(site.url)
    
    site.checks.create!(
      status: result[:status],
      duration_ms: result[:duration_ms],
      error: result[:error],
      checked_at: Time.current
    )
  end
end
