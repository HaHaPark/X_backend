# app/controllers/api/v1/progress_controller.rb
module Api
  module V1
    class ProgressController < ApplicationController
      before_action :authorize_request
      before_action :set_workspace

      # GET /api/v1/workspaces/:id/progress
      def index
        # 1) そのワークスペース内のタスクから担当ユーザーを抽出（重複排除）
        users_with_tasks = @workspace.tasks.includes(:user).map(&:user).uniq

        # 2) 各担当ユーザーごとに集計
        report = users_with_tasks.map do |user|
          total     = @workspace.tasks.where(user: user).count
          completed = @workspace.tasks.where(user: user, status: 'completed').count
          {
            user: {
              id:   user.id,
              name: user.name
            },
            total_tasks:     total,
            completed_tasks: completed,
            progress_rate:   total.positive? ? (completed * 100 / total).to_i : 0
          }
        end

        render json: report, status: :ok
      end

      private

      def set_workspace
        # params[:id] を使っていることに注意
        @workspace = @current_user.workspaces.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ['ワークスペースが見つからないか、アクセス権限がありません。'] },
               status: :not_found
      end
    end
  end
end
