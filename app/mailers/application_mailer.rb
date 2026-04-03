class ApplicationMailer < ActionMailer::Base
  # BUG FIX: was hardcoded "from@example.com", which overrides the SMTP_FROM
  # env var set in config/environments/production.rb because class-level mailer
  # defaults take precedence over Rails' config.action_mailer.default_options.
  default from: ENV.fetch("SMTP_FROM", "alerts@syncope.local")
  layout "mailer"
end
