# Setup

## Prerequisites

- Ruby 3.4.9 — install via [rbenv](https://github.com/rbenv/rbenv) or [mise](https://mise.jdx.dev/)
- Bundler — `gem install bundler`
- Git

## Local development

Clone the repository and install dependencies:

```bash
git clone https://github.com/your-username/syncope.git
cd syncope
bundle install
```

Prepare the database (creates it, runs migrations, loads schema):

```bash
bin/rails db:prepare
```

Start the development server:

```bash
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000).

## Running background jobs in development

Solid Queue does not run automatically in development by default. To process jobs locally, run the queue worker in a second terminal:

```bash
bin/jobs
```

Or use the Rails runner to trigger a single ping manually:

```bash
bin/rails runner "SitePinger.ping('https://example.com').then { |r| puts r }"
```

## Running tests

Unit and integration tests:

```bash
bin/rails test
```

System tests (requires a browser driver — Selenium with Chrome):

```bash
bin/rails test:system
```

Security audit:

```bash
bundle exec brakeman
bundle exec bundler-audit check --update
```

## Environment variables

Syncope uses Rails encrypted credentials for sensitive values. To edit them:

```bash
bin/rails credentials:edit
```

For production deployments, the following should be set:

| Key | Description |
|---|---|
| `secret_key_base` | Rails session encryption key (auto-generated) |
| `smtp_address` | SMTP server for email alerts |
| `smtp_username` | SMTP authentication username |
| `smtp_password` | SMTP authentication password |

## Production deployment with Kamal

Kamal deploys Syncope as a Docker container to any Linux server over SSH.

Edit `config/deploy.yml` to set your server IP, image registry, and domain. Then:

```bash
kamal setup   # first time only — installs Docker, sets up the server
kamal deploy  # subsequent deployments
```

See the [Kamal documentation](https://kamal-deploy.org) for full configuration options.

## Updating

Pull the latest changes and re-deploy:

```bash
git pull
bundle install
bin/rails db:migrate
bin/rails server
```
