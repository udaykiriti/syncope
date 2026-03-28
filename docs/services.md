# Services

## SitePinger

**File:** `app/services/site_pinger.rb`
**Type:** Plain Ruby class (no Rails dependencies)
**Purpose:** Makes an HTTP HEAD request to a given URL and returns the status code, response time in milliseconds, and any error that occurred.

### Interface

```ruby
SitePinger.ping(url_string) => Hash
```

**Input:**
- `url_string` — A fully qualified URL string, e.g. `"https://example.com"`

**Output — success:**
```ruby
{ status: 200, duration_ms: 143, error: nil }
```

**Output — timeout:**
```ruby
{ status: 504, duration_ms: nil, error: "Connection Timed Out" }
```

**Output — any other failure:**
```ruby
{ status: 0, duration_ms: nil, error: "getaddrinfo: Name or service not known" }
```

### How it works

1. The URL string is parsed into a `URI` object to extract the host, port, path, and scheme.
2. A monotonic clock timestamp is recorded before the request begins (`Process::CLOCK_MONOTONIC` is immune to system clock adjustments).
3. `Net::HTTP.start` opens a connection to the host. SSL is used automatically when the scheme is `https`. Both `open_timeout` and `read_timeout` are set to 5 seconds.
4. A `HEAD` request is sent to the URL path. If the path is empty (e.g. the URL is just a bare domain), `/` is used instead.
5. A second timestamp is taken after the response arrives. The difference is multiplied by 1000 and rounded to get milliseconds.
6. The status code, duration, and a nil error are returned.
7. If the connection times out at any stage, `Net::OpenTimeout` or `Net::ReadTimeout` is rescued, and a 504 status is returned with the "Connection Timed Out" error string.
8. All other exceptions are caught by a broad `StandardError` rescue. The exception message is returned as the error string and status is set to 0.

### Why HEAD requests

An HTTP HEAD request is identical to a GET request except the server does not send a response body. We receive all the headers (including the status code), but none of the HTML. For a site like a CDN-backed landing page, a GET response could be hundreds of kilobytes. A HEAD response is a few hundred bytes. When Syncope is pinging many sites every minute, this difference is significant.

### Why monotonic clock

`Time.now` and `Time.current` read the system's wall clock, which can be adjusted by NTP or DST changes while the request is in flight. `Process.clock_gettime(Process::CLOCK_MONOTONIC)` reads a counter that only moves forward and is never adjusted. This gives accurate elapsed time measurements regardless of system clock changes.

### Timeouts

Both `open_timeout` and `read_timeout` are set to 5 seconds. This means:
- If the TCP connection cannot be established within 5 seconds, the request is aborted.
- If the connection is established but no response bytes arrive within 5 seconds, the request is aborted.

Without these timeouts, a single hung server could block a background worker thread indefinitely.

### Testing in isolation

Because `SitePinger` has no Rails dependencies, you can run and test it with plain Ruby:

```bash
ruby app/services/site_pinger.rb
```

Add test calls at the bottom of the file during development:

```ruby
p SitePinger.ping("https://kernel.org")
p SitePinger.ping("https://this-does-not-exist-404.com")
```
