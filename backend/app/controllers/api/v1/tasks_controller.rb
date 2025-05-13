# app/controllers/api/v1/tasks_controller.rb
module Api
  module V1
    class TasksController < ApplicationController
      before_action :authorize_request
      before_action :set_workspace, only: [:index, :create]
      before_action :set_task,      only: [:show, :update, :destroy]

      # GET /api/v1/workspaces/:workspace_id/tasks
      # ?assignee_id=&category=&status= filter
      def index
        filters = {
          assignee_id: params[:assignee_id],
          category:    params[:category],
          status:      params[:status]
        }.compact
        result = TaskService.list(@workspace, filters)
        render json: result.tasks, status: :ok
      end

      # GET /api/v1/tasks/:id
      def show
        result = TaskService.show(@task.workspace, @task.id)
        if result.success?
          render json: result.task, status: :ok
        else
          render json: { errors: result.errors }, status: :not_found
        end
      end

      # POST /api/v1/workspaces/:workspace_id/tasks
      def create
        result = TaskService.create(@workspace, task_params, @current_user)
        if result.success?
          render json: result.task, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/tasks/:id
      def update
        result = TaskService.update(@task.id, task_params)
        if result.success?
          render json: result.task, status: :ok
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/tasks/:id
      def destroy
        result = TaskService.delete(@task.id)
        if result.success?
          head :no_content
        else
          render json: { errors: result.errors }, status: :not_found
        end
      end

      private

      def set_workspace
        @workspace = @current_user.workspaces.find(params[:workspace_id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ['Workspace not found or access denied'] }, status: :not_found
      end

      def set_task
        @task = Task.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ['Task not found'] }, status: :not_found
      end

      def task_params
        params.require(:task).permit(:title, :content, :status, :due_date, :category)
      end
    end
  end
end
