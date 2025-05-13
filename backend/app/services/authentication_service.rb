# app/services/authentication_service.rb
class AuthenticationService
  # login
  AuthResult = Struct.new(:success?, :user, :errors)

  def self.authenticate(email, password)
    user = User.find_by(email: email)
    if user&.authenticate(password)
      AuthResult.new(true, user, nil)
    else
      AuthResult.new(false, nil, ['メールアドレスまたはパスワードが正しくありません。'])
    end
  end
end
