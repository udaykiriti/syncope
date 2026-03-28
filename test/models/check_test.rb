require "test_helper"

class CheckTest < ActiveSupport::TestCase
  def valid_check(site)
    Check.new(site: site, status: 200, duration_ms: 143, checked_at: Time.current)
  end

  # --- Valid record ---

  test "saves a valid check" do
    check = valid_check(sites(:kernel))
    assert check.valid?, check.errors.full_messages.inspect
  end

  # --- Presence validations ---

  test "is invalid without a status" do
    check = valid_check(sites(:kernel))
    check.status = nil
    assert_not check.valid?
    assert_includes check.errors[:status], "can't be blank"
  end

  test "is invalid without checked_at" do
    check = valid_check(sites(:kernel))
    check.checked_at = nil
    assert_not check.valid?
    assert_includes check.errors[:checked_at], "can't be blank"
  end

  # --- Association ---

  test "requires a site" do
    check = Check.new(status: 200, duration_ms: 100, checked_at: Time.current)
    assert_not check.valid?
    assert_includes check.errors[:site], "must exist"
  end

  test "belongs to a site" do
    assert_equal sites(:kernel), checks(:one).site
  end

  # --- Nullability: error and duration_ms are optional ---

  test "is valid with nil duration_ms (timeout scenario)" do
    check = valid_check(sites(:kernel))
    check.duration_ms = nil
    assert check.valid?, check.errors.full_messages.inspect
  end

  test "is valid with nil error on success" do
    check = valid_check(sites(:kernel))
    check.error = nil
    assert check.valid?, check.errors.full_messages.inspect
  end
end
