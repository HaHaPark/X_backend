# app/services/workspace_service.rb
class WorkspaceService
  ListResult   = Struct.new(:success?, :workspaces, :errors)
  ShowResult   = Struct.new(:success?, :workspace,  :errors)
  CreateResult = Struct.new(:success?, :workspace,  :errors)
  UpdateResult = Struct.new(:success?, :workspace,  :errors)
  DeleteResult = Struct.new(:success?, :errors)

  # all Workspace
  def self.list_for_user(user)
    ListResult.new(true, user.workspaces, nil)
  end

  # Workspace delete
  def self.show_for_user(user, id)
    ws = user.workspaces.find_by(id: id)
    if ws
      ShowResult.new(true, ws, nil)
    else
      ShowResult.new(false, nil, ['Workspace not found or access denied'])
    end
  end

  # Workspace create
  def self.create(user, params)
    ws = Workspace.new(params)
    if ws.save
      WorkspaceUser.create!(workspace: ws, user: user)
      CreateResult.new(true, ws, nil)
    else
      CreateResult.new(false, nil, ws.errors.full_messages)
    end
  end

  # Workspace update
  def self.update(id, params)
    ws = Workspace.find_by(id: id)
    return UpdateResult.new(false, nil, ['Workspace not found']) unless ws

    if ws.update(params)
      UpdateResult.new(true, ws, nil)
    else
      UpdateResult.new(false, nil, ws.errors.full_messages)
    end
  end

  # Workspace delete
  def self.delete(id)
    ws = Workspace.find_by(id: id)
    return DeleteResult.new(false, ['Workspace not found']) unless ws

    ws.destroy
    DeleteResult.new(true, nil)
  end
end
