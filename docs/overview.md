# Overview

## What is Syncope

Syncope is a self-hosted uptime monitoring tool. It watches over your websites and services, checks whether they are alive at regular intervals, measures how fast they respond, and alerts you the moment something goes wrong.

The name comes from medicine — syncope means a sudden, temporary loss of consciousness, a "fainting" episode. A website that goes down has fainted. Syncope is the monitor watching for that moment.

## Why self-hosted

Most uptime monitoring services are cloud-based SaaS products. You hand over your URLs, your alert contacts, and your data to a third party and pay a monthly fee. Syncope takes the opposite approach: you run it yourself, on your own infrastructure. No accounts, no subscriptions, no black boxes. The code is open, the data is yours, and the tool costs nothing beyond the server you choose to run it on.

## How it works

At its core, Syncope is a loop:

1. You add a website URL to Syncope.
2. A background job runs on a schedule (every 60 seconds by default) and sends an HTTP HEAD request to that URL.
3. The response — status code and response time — is saved to the database as a Check record.
4. The dashboard reads those Check records and shows you the current status, history, and average response time for every site.
5. If a site returns a non-2xx status code or times out, Syncope marks it as down and can alert you.

The pinger uses HTTP HEAD requests deliberately — they ask the server for just the response headers, not the full HTML body. This is faster and uses almost no bandwidth, which matters when you are pinging dozens of sites every minute.

## Design principles

- Simple to self-host. One server, one database, no external dependencies.
- Transparent. The code does exactly what it says. No magic.
- Reliable. Strict timeouts prevent the app from hanging. Every error is caught and recorded.
- Minimal. No unnecessary features. Every addition must earn its place.
