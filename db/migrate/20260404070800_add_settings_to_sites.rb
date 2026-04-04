class AddSettingsToSites < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :check_interval_seconds, :integer, default: 60, null: false
    add_column :sites, :alert_email, :string
  end
end
