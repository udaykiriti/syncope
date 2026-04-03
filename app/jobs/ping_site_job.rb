class PingSiteJob < ApplicationJob
  queue_as :default

  def perform(site_id)
    site = Site.find_by(id: site_id)
    return unless site

    result = SitePinger.ping(site.url)

    # BUG FIX: capture the check object returned by create! and pass it directly
    # to the mailer below. Previously we called site.latest_check, but latest_check
    # is a has_one association with its own cache that is NOT cleared by
    # site.checks.reset — so it could return the stale pre-ping check.
    check = site.checks.create!(
      status:      result[:status],
      duration_ms: result[:duration_ms],
      error:       result[:error],
      checked_at:  Time.current
    )

    # Bust the has_many cache so status_transition/two_latest_checks query fresh rows.
    site.checks.reset

    # Guard: skip alerts entirely if no recipient is configured.
    # TODO: (Phase 5 follow-up) support per-site alert recipients stored in the
    # sites table rather than a single global env var.
    return unless ENV["ALERT_EMAIL_TO"].present?

    transition = site.status_transition
    if transition && site.needs_alert?(transition)
      case transition
      when :went_down
        AlertMailer.site_down(site, check).deliver_later
      when :recovered
        AlertMailer.site_recovered(site, check).deliver_later
      end

      # BUG FIX: Update the last alerted status to prevent duplicate alerts.
      site.update!(last_alerted_status: transition.to_s)
    end

    # FIXME: if deliver_later itself raises (e.g. Solid Queue is down), this job
    # will be retried and could double-alert. Consider idempotency via a
    # last_alerted_at timestamp column on sites, or a separate AlertJob.
  end
end
