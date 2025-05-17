# app/controllers/api/v1/progress_controller.rb
module Api
  module V1
    class ProgressController < ApplicationController
      before_action :authorize_request
      before_action :set_workspace

      # GET /api/v1/workspaces/:id/progress
      def index
        reports = ProgressReport
                    .where(workspace: @workspace)
                    .includes(:user)
                    .order(progress_rate: :desc)

        render json: reports.as_json(
          include: { user: { only: [:id, :name] } },
          only:    [:total_tasks, :completed_tasks, :progress_rate, :aggregated_at]
        )
      end

      private

      def set_workspace
        
        @workspace = @current_user.workspaces.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ['ワークスペースが見つからないか、アクセス権限がありません。'] },
               status: :not_found
      end
    end
  end
end
