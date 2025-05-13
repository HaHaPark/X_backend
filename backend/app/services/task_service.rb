# app/services/task_service.rb
class TaskService
  ListResult   = Struct.new(:success?, :tasks,   :errors)
  ShowResult   = Struct.new(:success?, :task,    :errors)
  CreateResult = Struct.new(:success?, :task,    :errors)
  UpdateResult = Struct.new(:success?, :task,    :errors)
  DeleteResult = Struct.new(:success?, :errors)

  # 1) all task get
  # filters = { assignee_id:, category:, status: }
  def self.list(workspace, filters = {})
    tasks = workspace.tasks.order(:due_date)
    tasks = tasks.where(user_id: filters[:assignee_id]) if filters[:assignee_id]
    tasks = tasks.where(category:    filters[:category])    if filters[:category]
    tasks = tasks.where(status:      filters[:status])      if filters[:status]
    ListResult.new(true, tasks, nil)
  end

  # 2) task get
  def self.show(workspace, id)
    task = workspace.tasks.find_by(id: id)
    task ? ShowResult.new(true, task, nil) : ShowResult.new(false, nil, ['Task not found'])
  end

  # 3) task create
  def self.create(workspace, params, user)
    task = workspace.tasks.build(params.merge(user: user))
    if task.save
      CreateResult.new(true, task, nil)
    else
      CreateResult.new(false, nil, task.errors.full_messages)
    end
  end

  # 4) task update
  def self.update(id, params)
    task = Task.find_by(id: id)
    return UpdateResult.new(false, nil, ['Task not found']) unless task

    if task.update(params)
      UpdateResult.new(true, task, nil)
    else
      UpdateResult.new(false, nil, task.errors.full_messages)
    end
  end

  # 5) task delete
  def self.delete(id)
    task = Task.find_by(id: id)
    return DeleteResult.new(false, ['Task not found']) unless task

    task.destroy
    DeleteResult.new(true, nil)
  end
end
