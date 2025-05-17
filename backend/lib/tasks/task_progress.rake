# lib/tasks/task_progress.rake
namespace :task_progress do
  desc "ProgressReport table upsert"
  task aggregate: :environment do
    Workspace.find_each do |ws|
      ws.users.find_each do |user|
        total     = ws.tasks.where(user: user).count
        completed = ws.tasks.where(user: user, status: 'completed').count
        rate      = total.positive? ? (completed * 100.0 / total).round(1) : 0.0

        ProgressReport.upsert(
          {
            workspace_id:    ws.id,
            user_id:         user.id,
            total_tasks:     total,
            completed_tasks: completed,
            progress_rate:   rate,
            aggregated_at:   Time.current
          },
          unique_by: %i[workspace_id user_id]
        )
      end
    end

    puts "[#{Time.current}] task_progress:aggregate complete"
  end
end
