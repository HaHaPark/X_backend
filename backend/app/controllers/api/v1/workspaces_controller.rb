# app/controllers/api/v1/workspaces_controller.rb
module Api
  module V1
    class WorkspacesController < ApplicationController
      before_action :authorize_request

      # GET /api/v1/workspaces
      def index
        result = WorkspaceService.list_for_user(@current_user)
        render json: result.workspaces, status: :ok
      end

      # GET /api/v1/workspaces/:id
      def show
        result = WorkspaceService.show_for_user(@current_user, params[:id])
        if result.success?
          render json: result.workspace, status: :ok
        else
          render json: { errors: result.errors }, status: :not_found
        end
      end

      # POST /api/v1/workspaces
      def create
        result = WorkspaceService.create(@current_user, workspace_params)
        if result.success?
          render json: result.workspace, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/workspaces/:id
      def update
        result = WorkspaceService.update(params[:id], workspace_params)
        if result.success?
          render json: result.workspace, status: :ok
        else
          render json: { errors: result.errors }, status: :not_found
        end
      end

      # DELETE /api/v1/workspaces/:id
      def destroy
        result = WorkspaceService.delete(params[:id])
        if result.success?
          head :no_content
        else
          render json: { errors: result.errors }, status: :not_found
        end
      end

      # POST /api/v1/workspaces/:id/join
      def join
        result = WorkspaceService.join(params[:id], @current_user)
        if result.success?
          render json: { message: 'ワークスペースに参加しました。' }, status: :ok
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      private

      def workspace_params
        params.require(:workspace).permit(:name, :description)
      end
    end
  end
end
