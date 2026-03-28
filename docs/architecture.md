# Architecture

## Folder structure

```
syncope/
├── app/
│   ├── assets/
│   │   └── stylesheets/
│   │       └── application.css        # Global styles — dark theme, design tokens
│   ├── controllers/
│   │   ├── application_controller.rb  # Base controller
│   │   └── pages_controller.rb        # Landing and dashboard pages
│   ├── javascript/
│   │   └── controllers/               # Stimulus controllers (Hotwire)
│   ├── jobs/
│   │   └── ping_job.rb                # Solid Queue job — fires SitePinger on schedule
│   ├── models/
│   │   ├── site.rb                    # A monitored website
│   │   └── check.rb                   # A single ping result (status, latency, time)
│   ├── services/
│   │   └── site_pinger.rb             # The Engine — makes HTTP requests, measures latency
│   └── views/
│       ├── layouts/
│       │   └── application.html.erb   # Root layout
│       └── pages/
│           ├── landing.html.erb       # Splash/entry page
│           └── dashboard.html.erb     # Main monitoring view
├── config/
│   ├── routes.rb                      # URL routing
│   ├── database.yml                   # SQLite config
│   ├── recurring.yml                  # Solid Queue — scheduled ping interval
│   └── importmap.rb                   # JS module pins
└── db/
    ├── schema.rb                      # Current database schema (auto-generated)
    └── seeds.rb                       # Optional: seed data for dev
```

## Data flow

```
[Background Job: PingJob]
        |
        | every 60 seconds, for each Site
        v
[Service: SitePinger.ping(url)]
        |
        | returns { status:, duration_ms:, error: }
        v
[Model: Check.create(...)]
        |
        | persisted to SQLite
        v
[Controller: PagesController#dashboard]
        |
        | queries Site.all with latest Check
        v
[View: dashboard.html.erb]
        |
        | renders status, latency, uptime history
        v
[Browser — Hotwire Turbo for live updates]
```

## Key design decisions

**SitePinger is a plain Ruby class, not a Rails model or controller.**
This keeps it independently testable. You can run it with `ruby app/services/site_pinger.rb` without booting Rails.

**Checks are immutable records.**
Each ping writes a new row. Nothing is updated or deleted. This gives you a full history of every check, which makes uptime percentage calculations trivial.

**HEAD requests over GET requests.**
We never download the page body. We only need the status code and response time. This is an order of magnitude faster and lighter on the target server.

**SQLite over Postgres.**
Self-hosted tools should not require a separate database daemon. SQLite is a single file, zero-config, and more than fast enough for the write volume Syncope generates (one row per site per minute).

**Solid Queue, Cache, and Cable over Redis.**
Rails 8's Solid stack replaces Redis-backed adapters with database-backed ones. Again, fewer moving parts means easier self-hosting.
