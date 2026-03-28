require "test_helper"

class SiteTest < ActiveSupport::TestCase
  # --- Valid record ---

  test "saves a valid site" do
    site = Site.new(name: "Kernel.org", url: "https://kernel.org")
    assert site.valid?, site.errors.full_messages.inspect
  end

  # --- Presence validations ---

  test "is invalid without a name" do
    site = Site.new(url: "https://example.com")
    assert_not site.valid?
    assert_includes site.errors[:name], "can't be blank"
  end

  test "is invalid without a url" do
    site = Site.new(name: "My Site")
    assert_not site.valid?
    assert_includes site.errors[:url], "can't be blank"
  end

  # --- URL format validation ---

  test "is invalid when url lacks http/https scheme" do
    site = Site.new(name: "Bad URL", url: "example.com")
    assert_not site.valid?
    assert_includes site.errors[:url], "must begin with http:// or https://"
  end

  test "accepts http:// urls" do
    site = Site.new(name: "HTTP Site", url: "http://example.com")
    assert site.valid?, site.errors.full_messages.inspect
  end

  test "accepts https:// urls" do
    site = Site.new(name: "HTTPS Site", url: "https://example.com")
    assert site.valid?, site.errors.full_messages.inspect
  end

  # --- Association ---

  test "has many checks" do
    assert_respond_to sites(:kernel), :checks
  end

  test "destroying a site destroys its checks" do
    site = sites(:kernel)
    site.checks.create!(status: 200, duration_ms: 50, checked_at: Time.current)
    assert_difference "Check.count", -site.checks.count do
      site.destroy
    end
  end
end
