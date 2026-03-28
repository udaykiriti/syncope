# Roadmap

Syncope is built in phases. Each phase produces a working, useful increment of the application.

---

## Phase 1 — The Engine

**Status: In progress**

Build the core HTTP pinger as a standalone Ruby service class. This is the fundamental piece everything else depends on. No Rails, no database, no UI — just a class that takes a URL and tells you if it is alive.

Deliverables:
- `app/services/site_pinger.rb`
- Returns status code, response time in ms, and error message
- Handles timeouts and all failure modes gracefully
- Testable with plain `ruby` command, no Rails boot required

---

## Phase 2 — Database Models

**Status: Planned**

Define the data schema. Two models:

**Site** — represents a website being monitored.

| Column | Type | Notes |
|---|---|---|
| `id` | integer | primary key |
| `name` | string | human-readable label, e.g. "My Blog" |
| `url` | string | fully qualified URL, e.g. "https://example.com" |
| `created_at` | datetime | |
| `updated_at` | datetime | |

**Check** — represents a single ping result.

| Column | Type | Notes |
|---|---|---|
| `id` | integer | primary key |
| `site_id` | integer | foreign key to `Site` |
| `status` | integer | HTTP status code returned |
| `duration_ms` | integer | response time in milliseconds |
| `error` | string | null on success, message on failure |
| `checked_at` | datetime | when the ping was executed |

Deliverables:
- Rails migrations for both models
- Model validations (URL format, presence checks)
- `Site` has_many `Check`
- `Check` belongs_to `Site`

---

## Phase 3 — Real Dashboard

**Status: Planned**

Replace the placeholder dashboard with a live view of all monitored sites. Each site shows:
- Current status (up / down)
- Last HTTP status code
- Last response time in ms
- Time since last check
- Uptime percentage (calculated from Check history)

Deliverables:
- `SitesController` with index, new, create, destroy
- Dashboard view with site cards
- Basic form to add a new site
- Status color coding (green = up, red = down)

---

## Phase 4 — Background Ping Scheduler

**Status: Planned**

A Solid Queue recurring job that automatically pings all sites on a schedule without any manual intervention.

Deliverables:
- `PingJob` in `app/jobs/ping_job.rb`
- Calls `SitePinger.ping` for each `Site` and creates a `Check` record
- Scheduled every 60 seconds in `config/recurring.yml`
- Dashboard reflects new data automatically (Turbo Stream)

---

## Phase 5 — Alerting

**Status: Planned**

Notify the user when a site transitions from up to down, and when it recovers.

Deliverables:
- Detect status transitions in the Check history
- Action Mailer email alerts (configurable SMTP)
- Optional webhook support (POST to a URL on status change)
- Alert cooldown to avoid floods on flapping sites

---

## Phase 6 — Analytics and History

**Status: Planned**

Show long-term trends. How reliable has each site been over the past 7 / 30 / 90 days?

Deliverables:
- Uptime percentage over selectable time ranges
- Response time chart (sparkline or full chart)
- Incident timeline (every period the site was down)
- Automatic pruning of old Check records beyond a configurable retention window
