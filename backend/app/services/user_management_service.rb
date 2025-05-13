# app/services/user_management_service.rb
class UserManagementService
  # sign up
  RegisterResult = Struct.new(:success?, :user, :errors)

  
  def self.register(params)
    user = User.new(params)
    if user.save
      RegisterResult.new(true, user, nil)
    else
      RegisterResult.new(false, nil, user.errors.full_messages)
    end
  end

  # user list
  ListResult = Struct.new(:success?, :users)
  def self.list
    users = User.select(:id, :email, :name)
    ListResult.new(true, users)
  end
end
