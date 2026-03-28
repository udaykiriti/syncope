# Tech Stack

## Language

**Ruby 3.4.9**
Ruby is chosen for its expressiveness and Rails ecosystem. The `.ruby-version` file pins the exact version so every developer and deployment environment uses the same runtime.

## Framework

**Ruby on Rails 8.1.3**
Rails provides the full MVC structure, routing, ORM, background jobs, caching, and WebSockets — all in one coherent framework. Rails 8 ships the Solid stack (Queue, Cache, Cable) out of the box, eliminating the need for Redis.

## Database

**SQLite3 (via Active Record)**
SQLite is a single-file, serverless database. For a self-hosted tool with one user and predictable write volume, it is the right choice. It requires zero configuration and has no daemon to manage. Rails 8 introduced write-ahead logging (WAL) mode for SQLite by default, which significantly improves concurrent read performance.

## Web Server

**Puma**
Rails' default web server. Multi-threaded, production-grade, and works out of the box with no configuration for a single-server deployment.

## Asset Pipeline

**Propshaft**
The modern, minimal Rails asset pipeline. Unlike Sprockets, Propshaft does not transform or bundle assets — it simply serves them with digest fingerprinting for cache busting. Combined with Import Maps, no Node.js or bundler is needed at all.

## JavaScript

**Import Maps**
JavaScript modules are delivered natively via browser-native ES Module import maps. No Webpack, no Vite, no `node_modules`. Dependencies are pinned in `config/importmap.rb` and served directly.

**Hotwire: Turbo**
Turbo intercepts navigation and form submissions, replacing only the changed parts of the page rather than doing full page reloads. This gives the dashboard a fast, SPA-like feel without writing a single line of custom JavaScript.

**Hotwire: Stimulus**
Stimulus is a lightweight JavaScript framework for adding specific behaviors to HTML elements. It is used for any interactive component that Turbo alone cannot handle.

## Background Jobs

**Solid Queue**
Solid Queue is a database-backed Active Job adapter, included in Rails 8. It replaces Sidekiq/Redis for job processing. Jobs are stored in the SQLite database. Recurring jobs (the ping schedule) are defined in `config/recurring.yml`.

## Caching

**Solid Cache**
Database-backed Rails cache store. Replaces Memcached or Redis-backed caching.

## WebSockets / Action Cable

**Solid Cable**
Database-backed Action Cable adapter. Used to push live status updates to the dashboard without polling.

## Deployment

**Kamal**
Kamal is a Docker-based deployment tool built by the Rails team (formerly MRSK). It deploys the app as a Docker container to any Linux server via SSH. The deployment config lives in `config/deploy.yml`.

**Thruster**
A companion to Puma that adds HTTP asset caching, compression, and X-Sendfile support. Runs in front of Puma in production.

## Image Processing

**image_processing**
Active Storage dependency for image transformation. Included by default in the Rails 8 generator, kept in for future use (e.g., site favicons).

## Development / Testing

| Gem | Purpose |
|---|---|
| `debug` | Ruby's built-in debugger, available in dev and test |
| `brakeman` | Static analysis for security vulnerabilities |
| `bundler-audit` | Checks gems against known CVE databases |
| `rubocop-rails-omakase` | Rails team's opinionated Ruby style guide |
| `capybara` | System test DSL for browser-level testing |
| `selenium-webdriver` | Browser driver for Capybara system tests |
| `web-console` | In-browser REPL for exception pages in development |
