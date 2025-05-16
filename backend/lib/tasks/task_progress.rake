# lib/tasks/task_progress.rake
namespace :task_progress do
  desc "Save each user's task stats to Progress, unique by user_id"
  task aggregate: :environment do
    User.find_each do |user|
      total = Task.where(user: user).count
      done  = Task.where(user: user, status: "completed").count
      rate  = total.zero? ? 0 : (done.to_f / total * 100).round(1)

      Progress.upsert(
        { user_id: user.id, total: total, completed: done, rate: rate, updated_at: Time.current },
        unique_by: :user_id
      )
    end
    puts "[#{Time.current}] task_progress:aggregate 완료"
  end
end
