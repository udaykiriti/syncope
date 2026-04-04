require 'net/http'
require 'uri'

class SitePinger
  # The core ping method.
  # Takes a URL string and returns a Hash with :status, :duration_ms, and :error.
  def self.ping(url_string)
    uri = URI.parse(url_string)
    
    # Secure defaults for host/port if URI parsing is incomplete
    host = uri.host
    port = uri.port || (uri.scheme == 'https' ? 443 : 80)

    # Start a high-precision monotonic clock timer.
    # Unlike Time.now, this is immune to system clock adjustments during the request.
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    begin
      # We use a HEAD request to save bandwidth — we only need the status and headers,
      # not the full HTML response body.
      # Strict 5-second timeouts protect the app from hanging.
      response = Net::HTTP.start(
        host,
        port,
        use_ssl: uri.scheme == 'https',
        open_timeout: 5,
        read_timeout: 5
      ) do |http|
        # Use request_uri to include path AND query string (e.g. /search?q=ruby)
        # BUG FIX: Net::HTTP requires a leading slash if path is empty, which
        # request_uri provides for HTTP/HTTPS URIs.
        http.request_head(uri.request_uri)
      end

      # End the timer and calculate the duration in milliseconds.
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      duration_ms = ((end_time - start_time) * 1000).round

      { status: response.code.to_i, duration_ms: duration_ms, error: nil }

    rescue Net::OpenTimeout, Net::ReadTimeout
      { status: 504, duration_ms: nil, error: 'Connection Timed Out' }
    rescue StandardError => e
      { status: 0, duration_ms: nil, error: e.message }
    end
  end
end

if __FILE__ == $0
  # Test harness for standalone execution
  puts "── Syncope SitePinger Engine Test ──"
  
  # Test 1: A healthy site
  target1 = "https://kernel.org"
  puts "Pinging #{target1}..."
  result1 = SitePinger.ping(target1)
  puts "Result: #{result1}"
  puts "---"

  # Test 2: A fake/broken site
  target2 = "https://this-site-does-not-exist-syncope-test.com"
  puts "Pinging #{target2}..."
  result2 = SitePinger.ping(target2)
  puts "Result: #{result2}"
  puts "------------------------"
end
