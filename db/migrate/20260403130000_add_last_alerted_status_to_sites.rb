class AddLastAlertedStatusToSites < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :last_alerted_status, :string
  end
end
