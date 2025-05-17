# app/services/progress_service.rb
class ProgressService
  
  def self.list_for_workspace(workspace)
    Progress
      .where(workspace: workspace)
      .includes(:user)
      .order(:user_id)
      .map do |p|
        {
          user: {
            id:   p.user.id,
            name: p.user.name
          },
          total_tasks:     p.total,
          completed_tasks: p.completed,
          progress_rate:   p.rate.to_i,
          aggregated_at:   p.aggregated_at
        }
      end
  end
end
