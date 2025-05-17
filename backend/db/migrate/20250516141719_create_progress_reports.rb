# db/migrate/2025xxxxxx_create_progress_reports.rb
class CreateProgressReports < ActiveRecord::Migration[8.0]
  def change
    create_table :progress_reports do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :user,      null: false, foreign_key: true
      t.integer    :total_tasks,     null: false, default: 0
      t.integer    :completed_tasks, null: false, default: 0
      t.float      :progress_rate,   null: false, default: 0.0
      t.datetime   :aggregated_at,   null: false

      t.timestamps
    end

    add_index :progress_reports,
              [:workspace_id, :user_id],
              unique: true,
              name:   'idx_progress_reports_on_workspace_and_user'
  end
end
