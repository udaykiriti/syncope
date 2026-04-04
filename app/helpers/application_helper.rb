module ApplicationHelper
  # Returns a CSS class for latency color coding
  def latency_class(ms)
    return "" if ms.nil?
    if ms < 300
      "latency-fast"
    elsif ms < 1000
      "latency-warn"
    else
      "latency-slow"
    end
  end

  # Returns a CSS class for HTTP status code color coding
  def http_code_class(code)
    case code
    when 200..299 then "http-code--ok"
    when 300..399 then "http-code--redirect"
    else "http-code--error"
    end
  end

  # Generate a pure-CSS sparkline from an array of check records
  # Returns HTML safe string of bars
  def sparkline_bars(checks, max_bars: 12)
    return "" if checks.empty?

    durations = checks.last(max_bars).map { |c| c.duration_ms || 0 }
    max_ms = [durations.max || 1, 1].max.to_f

    bars = durations.map do |ms|
      height = [(ms / max_ms * 100).round, 3].max
      color_class = latency_class(ms)
      css_color = case color_class
                  when "latency-fast" then "var(--green)"
                  when "latency-warn" then "var(--amber)"
                  when "latency-slow" then "var(--red)"
                  else "var(--text-3)"
                  end
      "<span class='spark-bar' style='height:#{height}%;background:#{css_color}' title='#{ms}ms'></span>"
    end

    bars.join.html_safe
  end
end
