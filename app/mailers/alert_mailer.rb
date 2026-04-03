class AlertMailer < ApplicationMailer
  # Sent when a site transitions from up to down.
  # The ALERT_EMAIL_TO guard lives in PingSiteJob — by the time this mailer is
  # called, we know a recipient is configured.
  #
  # TODO: (Phase 5 follow-up) add webhook support — POST to a per-site
  # `webhook_url` column on status change. Requires a migration and a separate
  # WebhookDeliveryJob to handle retries/timeouts cleanly.
  def site_down(site, check)
    @site  = site
    @check = check
    mail(
      to:      ENV["ALERT_EMAIL_TO"],
      subject: "[Syncope] #{@site.name} is DOWN"
    )
  end

  # Sent when a site transitions from down back to up.
  def site_recovered(site, check)
    @site  = site
    @check = check
    mail(
      to:      ENV["ALERT_EMAIL_TO"],
      subject: "[Syncope] #{@site.name} has recovered"
    )
  end
end
