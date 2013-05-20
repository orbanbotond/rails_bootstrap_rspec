class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.admin?
    elsif user.buyer?
    elsif user.supplier?
    end
      
    # :read, :create, :update and :destroy
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
