class CreateChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :checks do |t|
      t.references :site, null: false, foreign_key: true

      t.integer :status,      null: false
      t.integer :duration_ms
      t.string  :error
      t.datetime :checked_at, null: false
    end
  end
end
